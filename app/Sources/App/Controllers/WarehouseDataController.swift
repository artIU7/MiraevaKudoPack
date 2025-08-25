//
//  WarehouseDataController.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehouseDataController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let warehouse_data = routes.grouped("warehouse_data")
        warehouse_data.get(use: self.index)
        warehouse_data.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        warehouse_data.post(use: self.create)
        warehouse_data.post("warehouses",use: self.createArray)
        warehouse_data.group(":warehouse_dataID") { warehouse_data_selected in
            warehouse_data_selected.put(use: self.update)
            warehouse_data_selected.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [WarehouseDataDTO] {
        try await WarehouseDataModel.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func withWHID(req: Request) async throws -> [WarehouseDataDTO] {
        guard let warehouseId = req.parameters.get("warehouseId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        
        let warehouse = try await WarehouseDataModel.query(on: req.db)
            .filter(\.$id == warehouseId)
            .all()
        
        return warehouse.map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> WarehouseDataDTO {
        let warehouse_data = try req.content.decode(WarehouseDataDTO.self).toModel()
        try await warehouse_data.save(on: req.db)
        return warehouse_data.toDTO()
    }
    @Sendable
    func createArray(req: Request) async throws -> [WarehouseDataDTO] {
        let warehousesDTO = try req.content.decode([WarehouseDataDTO].self)
        let models = warehousesDTO.map { $0.toModel() }
        try await models.create(on: req.db)
        return models.map { $0.toDTO() }
    }
    @Sendable
    func update(req: Request) async throws -> WarehouseDataDTO {
      guard let warehouse_data = try await WarehouseDataModel.find(req.parameters.get("warehouse_dataID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedData = try req.content.decode(WarehouseDataDTO.self)
      if let warehouse_name = updatedData.warehouse_name {
          warehouse_data.warehouse_name = warehouse_name
      }
      if let warehouse_width = updatedData.warehouse_width {
          warehouse_data.warehouse_width = warehouse_width
      }
      if let warehouse_length = updatedData.warehouse_length {
          warehouse_data.warehouse_length = warehouse_length
      }

      try await warehouse_data.update(on: req.db)
      
      return warehouse_data.toDTO()
    }
        

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let warehouse_data = try await WarehouseDataModel.find(req.parameters.get("warehouse_dataID"), on: req.db) else {
            throw Abort(.notFound)
        }
        // Удаляем каскадно записи в БД для данного склада
        // Удаляем связанные записи
        try await KudoboxModel.query(on: req.db)
            .filter(\.$uuid_warehouse == warehouse_data.id!.uuidString)
            .delete()
        try await WarehouseSectionGeometryModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouse_data.id!.uuidString)
            .delete()
        try await WarehouseSectionModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouse_data.id!.uuidString)
            .delete()
       try await WarehousePointsModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouse_data.id!.uuidString)
            .delete()
        try await WarehouseEdgeModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouse_data.id!.uuidString)
            .delete()
        try await UserDataModel.query(on: req.db)
            .filter(\.$uuid_warehouse == warehouse_data.id!.uuidString)
            .delete()

        //  Получаем все заказы для данного склада
        let orders = try await OrderItemModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouse_data.id!.uuidString)
            .all()

        // Для каждого заказа удаляем связанные записи
        for order in orders {
            guard let orderId = order.id else { continue }
            // Удаляем параметры упаковки
            try await OrderPakingParamModel.query(on: req.db)
                .filter(\.$id_order_item == orderId.uuidString)
                .delete()
    
            // Удаляем данные заказа
            try await OrderDataModel.query(on: req.db)
                .filter(\.$id_order_item == orderId.uuidString)
                .delete()
        }

        try await OrderItemModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouse_data.id!.uuidString)
            .delete()

        try await warehouse_data.delete(on: req.db)
        return .noContent
    }
}
