import Fluent
import Vapor

struct KudoBoxController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let kudobox = routes.grouped("kudobox")

        kudobox.get(use: self.index)
        // Маршрут для получения коробок по warehouseId
        kudobox.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        kudobox.post(use: self.create)
        kudobox.post("boxes",use: self.createArray)

        kudobox.group(":kudoboxID") { kudoboxSelected in
            kudoboxSelected.put(use: self.update)
            kudoboxSelected.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [KudoboxDTO] {
        try await KudoboxModel.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func withWHID(req: Request) async throws -> [KudoboxDTO] {
        guard let warehouseId = req.parameters.get("warehouseId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        
        let boxes = try await KudoboxModel.query(on: req.db)
            .filter(\.$uuid_warehouse == warehouseId)
            .all()
        
        return boxes.map { $0.toDTO() }
    }
    @Sendable
    func create(req: Request) async throws -> KudoboxDTO {
        let box_data = try req.content.decode(KudoboxDTO.self)
        // Если коробка с таким именем на складе существует, то не добавляем ее
        if let kudoBox = try await KudoboxModel.query(on: req.db )
            .filter(\.$sku_box == box_data.sku_box!)
            .filter(\.$uuid_warehouse == box_data.uuid_warehouse!)
            .first() {
            throw Abort(.badRequest, reason: "Коробка уже существует !")
        } else {
            try await box_data.toModel().save(on: req.db)
            return box_data.toModel().toDTO()
        }
    }
    @Sendable
    func createArray(req: Request) async throws -> [KudoboxDTO] {
        let boxesDTO = try req.content.decode([KudoboxDTO].self)
        var results: [KudoboxDTO] = []
    
        for dto in boxesDTO {
            if let existingBox = try await KudoboxModel.query(on: req.db)
                .filter(\.$sku_box == dto.sku_box!)
                .filter(\.$uuid_warehouse == dto.uuid_warehouse!)
                .first() {
                results.append(existingBox.toDTO())
            } else {
            let model = dto.toModel()
            try await model.save(on: req.db)
            results.append(model.toDTO())
            }
        }
        return results
    }
    
    @Sendable
    func update(req: Request) async throws -> KudoboxDTO {
      guard let kudoBox = try await KudoboxModel.find(req.parameters.get("kudoboxID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedData = try req.content.decode(KudoboxDTO.self)        
      if let sku_box = updatedData.sku_box {
          kudoBox.sku_box = sku_box
      }
      if let width_box = updatedData.width_box {
          kudoBox.width_box = width_box
      }
      if let length_box = updatedData.length_box {
        kudoBox.length_box = length_box
      }
      if let height_box = updatedData.height_box {
        kudoBox.height_box = height_box
      }
      if let weight_box = updatedData.weight_box {
        kudoBox.weight_box = weight_box
      }
      if let is_rotated_box = updatedData.is_rotated_box {
        kudoBox.is_rotated_box = is_rotated_box
      }
      if let max_load_box = updatedData.max_load_box {
        kudoBox.max_load_box = max_load_box
      }
      try await kudoBox.update(on: req.db)
      return kudoBox.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let kudoBox = try await KudoboxModel.find(req.parameters.get("kudoboxID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await kudoBox.delete(on: req.db)
        return .noContent
    }
}
