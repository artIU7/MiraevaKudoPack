//
// OrderPakingParamController.swift
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct OrderPakingParamController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let order_param = routes.grouped("order_param")

        order_param.get(use: self.index)
        // Маршрут для получения заказов по orderId
        order_param.get("withOrderID", ":orderId", use: self.withWHID)
        order_param.post(use: self.create)

        order_param.group(":paramID") { order_param_selected in
            order_param_selected.put(use: self.update)
            order_param_selected.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [OrderPakingParamDTO] {
        try await OrderPakingParamModel.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func withWHID(req: Request) async throws -> [OrderPakingParamDTO] {
        guard let orderId = req.parameters.get("orderId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        let params = try await OrderPakingParamModel.query(on: req.db)
            .filter(\.$id_order_item == orderId)
            .all()
        return params.map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> OrderPakingParamDTO {
        let params_order = try req.content.decode(OrderPakingParamDTO.self).toModel()
        try await params_order.save(on: req.db)
        return params_order.toDTO()
    }
    
    @Sendable
    func update(req: Request) async throws -> OrderPakingParamDTO {
      guard let order_params = try await OrderPakingParamModel.find(req.parameters.get("paramID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedData = try req.content.decode(OrderPakingParamDTO.self)
        if let id_order_item = updatedData.id_order_item {
            order_params.id_order_item = id_order_item
        }
        
        if let pallet_width = updatedData.pallet_width {
            order_params.pallet_width = pallet_width
        }
        
        if let pallet_length = updatedData.pallet_length {
            order_params.pallet_length = pallet_length
        }
        
        if let pallet_max_height = updatedData.pallet_max_height {
            order_params.pallet_max_height = pallet_max_height
        }
        
        if let min_support_ratio = updatedData.min_support_ratio {
            order_params.min_support_ratio = min_support_ratio
        }
        
        if let min_layer_fill_ratio = updatedData.min_layer_fill_ratio {
            order_params.min_layer_fill_ratio = min_layer_fill_ratio
        }
        
        if let height_tolerance = updatedData.height_tolerance {
            order_params.height_tolerance = height_tolerance
        }
        
        if let height_layer_diff = updatedData.height_layer_diff {
            order_params.height_layer_diff = height_layer_diff
        }
        
        if let packing_type = updatedData.packing_type {
            order_params.packing_type = packing_type
        }

      try await order_params.update(on: req.db)
      
      return order_params.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let params_order = try await OrderPakingParamModel.find(req.parameters.get("paramID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await params_order.delete(on: req.db)
        return .noContent
    }
}
