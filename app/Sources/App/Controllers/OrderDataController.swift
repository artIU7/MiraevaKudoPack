//
// OrderDataController.swift
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct OrderDataController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let order_data = routes.grouped("order_data")

        order_data.get(use: self.index)
        // Маршрут для получения заказов по orderId
        order_data.get("withOrderID", ":orderId", use: self.withWHID)
        order_data.post(use: self.create)
        order_data.post("data",use: self.createArray)

        order_data.group(":dataID") { order_data_selected in
            order_data_selected.put(use: self.update)
            order_data_selected.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [OrderDataDTO] {
        try await OrderDataModel.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func withWHID(req: Request) async throws -> [OrderDataDTO] {
        guard let orderId = req.parameters.get("orderId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        
        let data = try await OrderDataModel.query(on: req.db)
            .filter(\.$id_order_item == orderId)
            .all()
        
        return data.map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> OrderDataDTO {
        let order_data = try req.content.decode(OrderDataDTO.self)
        if let order_created = try await OrderDataModel.query(on: req.db)
            .filter(\.$id_box == order_data.id_box!)
            .filter(\.$id_order_item == order_data.id_order_item!)
            .first() {
            order_created.count_box += order_data.count_box!
            try await order_created.update(on: req.db)
            return order_created.toDTO()
        } else {
            try await order_data.toModel().save(on: req.db)
            return order_data.toModel().toDTO()
        }
    }
    
    @Sendable
    func createArray(req: Request) async throws -> [OrderDataDTO] {
        let dataDTO = try req.content.decode([OrderDataDTO].self)
        var results: [OrderDataDTO] = []
        for dto in dataDTO {
            if let order_created = try await OrderDataModel.query(on: req.db)
                .filter(\.$id_box == dto.id_box! )
                .filter(\.$id_order_item == dto.id_order_item! )
                .first() {
                order_created.count_box += dto.count_box!
                try await order_created.update(on: req.db)
                results.append(order_created.toDTO())
            } else {
                let model = dto.toModel()
                try await model.save(on: req.db)
                results.append(model.toDTO())
            }
        }
        return results
    }
    
    @Sendable
    func update(req: Request) async throws -> OrderDataDTO {
      guard let order_data = try await OrderDataModel.find(req.parameters.get("dataID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedData = try req.content.decode(OrderDataDTO.self)
              
        if let id_order_item = updatedData.id_order_item {
            order_data.id_order_item = id_order_item
        }
        
        if let id_box = updatedData.id_box {
            order_data.id_box = id_box
        }
        
        if let name_box = updatedData.name_box {
            order_data.name_box = name_box
        }
        
        if let count_box = updatedData.count_box {
            order_data.count_box = count_box
        }

      try await order_data.update(on: req.db)
      
      return order_data.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let order_data = try await OrderDataModel.find(req.parameters.get("dataID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await order_data.delete(on: req.db)
        return .noContent
    }
}
