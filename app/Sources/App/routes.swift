import Fluent
import Vapor

func dbRequestData(req: Request) async throws -> [KudoboxDTO] {
    let kudoBoxes = try await KudoboxModel.query(on: req.db).all()
    guard !kudoBoxes.isEmpty else {
        throw Abort(.notFound, reason: "No kudo boxes found")
    }
    return try kudoBoxes.map { try $0.toDTO() }
}

private func saveComputationResults(
    orderID: String,
    computedData: [String:[PalleteComputed]],
    req: Request
) async throws {
    let jsonData = try JSONEncoder().encode(computedData)
    guard let orderUUID = UUID(uuidString: orderID) else {
           throw Abort(.badRequest, reason: "Invalid order ID format")
    }    
    let orderItems = try await OrderItemModel.query(on: req.db)
        .filter(\.$id == orderUUID)
        .all()
    
    for var orderItem in orderItems {
        orderItem.pallete_computed = jsonData
        try await orderItem.update(on: req.db)
    }
}

struct APIDataValue: Encodable {
    let id: String
    let name: String 
    let baseURL: String
    let endpoint: String 
    let method: String 
    let description: String 
    let requestExample: String 
    let responseExample: String 
    let headers: String
    let queryParameters: String 
    let pathParameters: String
    let category: String

    var methodLowercased: String {
        return method.lowercased()
    }
    
    var methodUppercased: String {
        return method.uppercased()
    }
}
struct APIDocsContext: Encodable {
    let apis: [APIDataValue]  
    let categories: [String]
}
     
func routes(_ app: Application) throws {
    
    let api = app.grouped("api", "v1")
    let protected = api.grouped(UserBasicAuthenticator())
    // Защищенный метод для тестов с выводом в консоль размещенныз коробок на паллете
    // Коробки генерируются рандомно
    // Остальные методы - отключена обязательная авторизация
    protected.get("computed", ":randomHeight", ":randomBoxCount") { req async throws -> [PalleteComputed] in
        let user = try req.auth.require(UserDataModel.self)
        let randomHeight = req.parameters.get("randomHeight", as: String.self)
        let randomBoxCount = req.parameters.get("randomBoxCount", as: String.self)
        let maxHeight = Int(randomHeight ?? "") ?? 150
        let countBox = Int(randomBoxCount ?? "") ?? 50
        var boxes = (1...countBox).map { _ in
            Box(
                id: UUID(),
                sku_box: "SKU-\(Int.random(in: 1000...9999))",
                width_box: Int.random(in: 20...40),
                length_box: Int.random(in: 20...40),
                height_box: Int.random(in: 48...50),
                weight_box: Int.random(in: 500...1000),
                is_rotated_box: 1,
                max_load_box: Int.random(in: 500...2000),
                id_point_section: "",
                id_section: ""
            )
        }
        var packingPalleteController = PackingOnPallete()
        var palleteCompletePacking = packingPalleteController.packBoxesOnPallets(
            boxes: boxes,
            palletWidth: 80,
            palletLength: 120,
            maxPalletHeight: Double(maxHeight)
        )
        req.logger.info("Palletes :: \(palleteCompletePacking)")
        return packingPalleteController.convertPalletsToComputed(palleteCompletePacking)
    }
    // Тестовый маршрут вычисления пути от заданых точек : начала и конца на выбраннном складе 
    api.get("computed_route",":uuid_warehouse", ":uuid_point_from", ":uuid_point_to") { req async throws -> [String] in

        guard let warehouseId = req.parameters.get("uuid_warehouse") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        guard let uuid_point_from = req.parameters.get("uuid_point_from") else {
            throw Abort(.badRequest, reason: "Missing uuid_point_from parameter")
        }
        guard let uuid_point_to = req.parameters.get("uuid_point_to") else {
            throw Abort(.badRequest, reason: "Missing uuid_point_to parameter")
        }
        let warehouse_points = try await WarehousePointsModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .all()
        
        let warehouse_edge = try await WarehouseEdgeModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .all()

        let nodes = try warehouse_points.map { point in
            let dto = try point.toDTO()
            return Node(
                id: dto.id!.uuidString,
                x: dto.pos_x!,
                y: dto.pos_y!
            )
        }

        let edges = try warehouse_edge.map { edge in
            let dto = try edge.toDTO()
            return Edge(
                node1: dto.id_points_from!, 
                node2: dto.id_points_to!
            )
        }

        let dijkstra = DijkstraAlgorithm(nodes: nodes, edges: edges)        
        if let result = dijkstra.shortestPath(from: uuid_point_from, to: uuid_point_to)
        {
            return result.path
        }
        else
        {
            throw Abort(.notFound, reason: "Path not found between specified points")
        }
    }
    // Маршрут для комплектования коробок на паллете для выбранного заказа с учтом установленных параметров 
    // Основной метод - задачи 
    api.post("computed_order") { req async throws -> HTTPResponseStatus in
        
        struct ComputeRequest: Content {
                let id_order_item: String
                let id_warehouse: String
                let id_point_start : String
        }
            
        let request = try req.content.decode(ComputeRequest.self)
        let orderID  = request.id_order_item
        let whouseID = request.id_warehouse
        let pointID  = request.id_point_start
        
        Task {
            do {
                let order_data = try await OrderDataModel.query(on: req.db)
                    .filter(\.$id_order_item == orderID)
                    .all()
                
                let order_param = try await OrderPakingParamModel.query(on: req.db)
                    .filter(\.$id_order_item == orderID)
                    .all()
            
                let kudoBoxes = try await KudoboxModel.query(on: req.db)
                    .filter(\.$uuid_warehouse == whouseID)
                    .all()
                
                let geometrySectionModels = try await WarehouseSectionGeometryModel.query(on: req.db)
                    .filter(\.$id_warehouse == whouseID)
                    .all()
                
                let sectionModels = try await WarehouseSectionModel.query(on: req.db)
                    .filter(\.$id_warehouse == whouseID)
                    .all()
                
                let warehouse_points = try await WarehousePointsModel.query(on: req.db)
                    .filter(\.$id_warehouse == whouseID)
                    .all()
                
                let warehouse_edge = try await WarehouseEdgeModel.query(on: req.db)
                    .filter(\.$id_warehouse == whouseID)
                    .all()
                
                let nodes = try warehouse_points.map { point in
                    let dto = try point.toDTO()
                    return Node(
                        id: dto.id!.uuidString, 
                        x: dto.pos_x!,
                        y: dto.pos_y!
                    )
                }

                let edges = try warehouse_edge.map { edge in
                    let dto = try edge.toDTO()
                    return Edge(
                        node1: dto.id_points_from!, 
                        node2: dto.id_points_to! 
                    )
                }

                let dijkstra = DijkstraAlgorithm(nodes: nodes, edges: edges)
                
                var from_db_pallet_width : Int  = 100
                var from_db_pallet_length : Int = 120
                var from_db_pallet_max_height : Int = 200
                var from_db_min_support_ratio : Double = 70.0
                var from_db_min_layer_fill_ratio : Double = 70.0
                var from_db_height_tolerance : Double = 2.0
                var from_db_heightLayerDiff : Int = 0
                var from_db_type_packing : Int = 0

                for order_param_item in order_param {
                    let dto = try order_param_item.toDTO()
                    guard
                        let pallet_width         = dto.pallet_width,
                        let pallet_length        = dto.pallet_length,
                        let pallet_max_height    = dto.pallet_max_height,
                        let min_support_ratio    = dto.min_support_ratio,
                        let min_layer_fill_ratio = dto.min_layer_fill_ratio,
                        let height_tolerance     = dto.height_tolerance,
                        let heightLayerDiff      = dto.height_layer_diff,
                        let type_packing         = dto.packing_type
                    else { continue }
                    
                    from_db_pallet_width = pallet_width
                    from_db_pallet_length = pallet_length
                    from_db_pallet_max_height = pallet_max_height
                    from_db_min_support_ratio = min_support_ratio
                    from_db_min_layer_fill_ratio = min_layer_fill_ratio
                    from_db_height_tolerance = height_tolerance
                    from_db_heightLayerDiff = heightLayerDiff
                    from_db_type_packing = type_packing
                }
                
                // Параметры алгоритма
                // Минимальная площадь опоры для коробок размещаемых выше первого слоя ( % )
                minSupportRatio = from_db_min_support_ratio
                // Минимальное перекрытие слоя коробками ( % )
                minLayerFillRatio = from_db_min_layer_fill_ratio
                // Перепад высоты слоя ( см )
                heightTolerance = from_db_height_tolerance
                // Разрешаем собирать слои разной высоты
                heightLayerDiff = from_db_heightLayerDiff
                // Размещение коробок по углам паллеты для покрытия всей площади
                type_packing = from_db_type_packing
                
                var boxes: [Box] = []
                
                for orderItem in order_data {
                    let dto = try orderItem.toDTO()
                    guard
                        let boxId = dto.id_box,
                        let count = dto.count_box,
                        count > 0
                    else { continue }
                    
                    for kudoBox in kudoBoxes {
                        if kudoBox.id!.uuidString == boxId {
                            
                            var sectionUUID: String? = nil
                            for section in sectionModels {
                                if section.id_box == kudoBox.id!.uuidString {
                                    sectionUUID = section.id!.uuidString
                                    break
                                }
                            }
                            var uuidPoint: String? = nil
                            var uuidSection: String? = nil

                            if let sectionUUID = sectionUUID {
                                for geometrySection in geometrySectionModels {
                                    if geometrySection.id_warehouse_section == sectionUUID {
                                        uuidPoint = geometrySection.id_point_way
                                        uuidSection = geometrySection.id_warehouse_section
                                        break
                                    }
                                }
                            }
                             
                            for _ in 0..<count {
                                boxes.append(Box(
                                    id: kudoBox.id ?? UUID(),
                                    sku_box: kudoBox.sku_box,
                                    width_box: kudoBox.width_box,
                                    length_box: kudoBox.length_box,
                                    height_box: kudoBox.height_box,
                                    weight_box: kudoBox.weight_box,
                                    is_rotated_box: kudoBox.is_rotated_box,
                                    max_load_box: kudoBox.max_load_box,
                                    id_point_section: uuidPoint!,
                                    id_section: uuidSection!
                                ))
                            }
                            break
                        }
                    }
                }
                
                var packingPalleteController = PackingOnPallete()
                
                var palleteCompletePacking = packingPalleteController.packBoxesOnPallets(
                    boxes: boxes,
                    palletWidth: Double(from_db_pallet_width),
                    palletLength: Double(from_db_pallet_length),
                    maxPalletHeight: Double(from_db_pallet_max_height)
                )
                
                let computedPallets =
                packingPalleteController.sendComputedPalleteWithOrderID(orderID: orderID, pallete:              palleteCompletePacking,router_core: dijkstra, pointStart : pointID)
                req.logger.info("Computed with startPointID \(pointID)")

                try await saveComputationResults(
                            orderID: orderID,
                            computedData: computedPallets,
                            req: req
                    )
                req.logger.info("Successfully computed and saved order \(orderID)")
            } catch {
                req.logger.error("Failed to compute order \(orderID): \(error)")
            }
        }
        return .accepted
    }

    // Маршрут для вызова web приложения KudoWarehouse Managment
    // React.js(CСтатические стараницы приложения) - разворачиваем в том же контейнере для удобства 
    app.get { req -> Response in
    let filePath = req.application.directory.publicDirectory + "index.html"
        return req.fileio.streamFile(at: filePath)
    }
    // Перенаправление на страницу c Приложкиеам KudoWarehouse Managment 
    // Необходим для перезагрзки web приложения  на слюбой странице 
    app.get("**") { req -> Response in
    let filePath = req.application.directory.publicDirectory + "index.html"
        return req.fileio.streamFile(at: filePath)
    }

    app.get("api-docs") { req -> EventLoopFuture<View> in
    return APIDataModel.query(on: req.db).all()
        .flatMap { models in
            let apis = models.map { model in
                var dto = model.toDTO()
                var value = APIDataValue (
                        id : dto.id?.uuidString ?? UUID().uuidString,
                        name : dto.name ?? "Unnamed API",
                        baseURL : dto.baseURL ?? "/",
                        endpoint : dto.endpoint ?? "",
                        method : dto.method ?? "GET",
                        description : dto.description ?? "",
                        requestExample : dto.requestExample ?? "{}",
                        responseExample : dto.responseExample ?? "{}",
                        headers : dto.headers ?? "{}",
                        queryParameters : dto.queryParameters ?? "{}",
                        pathParameters : dto.pathParameters ?? "{}",
                        category : dto.category ?? "General"
                )
                return value
            }
        let categories = Array(Set(apis.map { $0.category })).sorted()
        let context = APIDocsContext(apis: apis, categories: categories)
        return req.view.render("ApiDocs/index", context)
    }
}

    try api.register(collection : KudoBoxController())
    try api.register(collection : WarehouseDataController())
    try api.register(collection : UserDataController())
    try api.register(collection : WarehouseSectionController())
    try api.register(collection : WarehouseSectionGeometryController())
    try api.register(collection : WarehousePointsController())
    try api.register(collection : WarehouseEdgeController())
    try api.register(collection : OrderItemController())
    try api.register(collection : OrderDataController())
    try api.register(collection : OrderPakingParamController())

    try app.register(collection : APIDataController())
}
