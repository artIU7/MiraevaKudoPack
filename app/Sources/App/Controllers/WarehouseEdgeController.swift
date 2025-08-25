//
// WarehouseEdgeController.swift
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehouseEdgeController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let warehouse_edge = routes.grouped("warehouse_edge")

        warehouse_edge.get(use: self.index)
        // Маршрут для получения points по warehouseId
        warehouse_edge.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        warehouse_edge.post(use: self.create)
        warehouse_edge.post("edges",use: self.createArray)
        warehouse_edge.group(":warehouse_sectionID") { warehouse_edge_selected in
            warehouse_edge_selected.put(use: self.update)
            warehouse_edge_selected.delete(use: self.delete)
        }
    }
    @Sendable
    func index(req: Request) async throws -> [WarehouseEdgeDTO] {
        try await WarehouseEdgeModel.query(on: req.db).all().map { $0.toDTO() }
    }
    @Sendable
    func withWHID(req: Request) async throws -> [WarehouseEdgeDTO] {
        guard let warehouseId = req.parameters.get("warehouseId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        let edges = try await WarehouseEdgeModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .all()
        return edges.map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> WarehouseEdgeDTO {
        let warehouse_edge = try req.content.decode(WarehouseEdgeDTO.self).toModel()
        try await warehouse_edge.save(on: req.db)
        return warehouse_edge.toDTO()
    }
    @Sendable
    func createArray(req: Request) async throws -> [WarehouseEdgeDTO] {
        let edgesDTO = try req.content.decode([WarehouseEdgeDTO].self)
        let models = edgesDTO.map { $0.toModel() }
        try await models.create(on: req.db)
        return models.map { $0.toDTO() }
    }
    @Sendable
    func update(req: Request) async throws -> WarehouseEdgeDTO {
      guard let warehouse_edges = try await WarehouseEdgeModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
          throw Abort(.notFound)
      }
        let updatedData = try req.content.decode(WarehouseEdgeDTO.self)
        if let name_points_from = updatedData.name_points_from {
            warehouse_edges.name_points_from = name_points_from
        }
        if let name_points_to = updatedData.name_points_to {
            warehouse_edges.name_points_to = name_points_to
        }
        if let id_points_from = updatedData.id_points_from {
            warehouse_edges.id_points_from = id_points_from
        }
        if let id_points_to = updatedData.id_points_to {
            warehouse_edges.id_points_to = id_points_to
        }
        
        if let id_warehouse = updatedData.id_warehouse {
            warehouse_edges.id_warehouse = id_warehouse
        }
        try await warehouse_edges.update(on: req.db)
        return warehouse_edges.toDTO()
    }
        

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let warehouse_edge = try await WarehouseEdgeModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await warehouse_edge.delete(on: req.db)
        return .noContent
    }
}
