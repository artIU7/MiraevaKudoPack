//
// OrderItemController.swift
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct OrderItemController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let order_item = routes.grouped("order_item")
        order_item.get(use: self.index)
        // Маршрут для получения заказов по warehouseId
        order_item.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        order_item.get("withWarehouseID", ":warehouseId","withOrderID",":orderItemId", use: self.withOrderID)
        order_item.post(use: self.create)
        order_item.group(":orderItemID") { order_item_selected in
            order_item_selected.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [OrderItemDTO] {
        try await OrderItemModel.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func withWHID(req: Request) async throws -> [OrderItemDTO] {
        guard let warehouseId = req.parameters.get("warehouseId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        let orders = try await OrderItemModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .all()
        return orders.map { $0.toDTO() }
    }
    
    @Sendable
    func withOrderID(req: Request) async throws -> [String: [PalleteComputed]] {
        guard
            let warehouseId = req.parameters.get("warehouseId"),
            let orderItemId = req.parameters.get("orderItemId", as: UUID.self)
        else {
            throw Abort(.badRequest, reason: "Missing required parameters")
        }
        guard let item = try await OrderItemModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .filter(\.$id == orderItemId)
            .first()
        else {
            throw Abort(.notFound, reason: "Order item not found in this warehouse")
        }
        // Декодируем pallete_computed
        var decodedData: [String: [PalleteComputed]] = [:]
        if !item.pallete_computed.isEmpty {
            decodedData = try JSONDecoder().decode([String: [PalleteComputed]].self, from: item.pallete_computed)
        }
        return decodedData
    }

    @Sendable
    func create(req: Request) async throws -> OrderItemDTO {
        let orders = try req.content.decode(OrderItemDTO.self).toModel()
        try await orders.save(on: req.db)
        return orders.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let order = try await OrderItemModel.find(req.parameters.get("orderItemID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await OrderPakingParamModel.query(on: req.db)
            .filter(\.$id_order_item == order.id!.uuidString)
            .delete()
        try await OrderDataModel.query(on: req.db)
            .filter(\.$id_order_item == order.id!.uuidString)
            .delete()
        try await order.delete(on: req.db)
        return .noContent
    }
}
