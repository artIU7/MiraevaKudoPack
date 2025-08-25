//
// WarehousePointsController.swift
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehousePointsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let warehouse_points = routes.grouped("warehouse_points")
        warehouse_points.get(use: self.index)
        // Маршрут для получения points по warehouseId
        warehouse_points.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        warehouse_points.post(use: self.create)
        warehouse_points.post("points",use: self.createArray)
        warehouse_points.group(":warehouse_sectionID") { warehouse_points_selected in
            warehouse_points_selected.put(use: self.update)
            warehouse_points_selected.delete(use: self.delete)
        }
    }
    @Sendable
    func index(req: Request) async throws -> [WarehousePointsDTO] {
        try await WarehousePointsModel.query(on: req.db).all().map { $0.toDTO() }
    }
    @Sendable
    func withWHID(req: Request) async throws -> [WarehousePointsDTO] {
        guard let warehouseId = req.parameters.get("warehouseId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        let points = try await WarehousePointsModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .all()
        
        return points.map { $0.toDTO() }
    }
    @Sendable
    func create(req: Request) async throws -> WarehousePointsDTO {
        let warehouse_points = try req.content.decode(WarehousePointsDTO.self).toModel()
        try await warehouse_points.save(on: req.db)
        return warehouse_points.toDTO()
    }
    @Sendable
    func createArray(req: Request) async throws -> [WarehousePointsDTO] {
        let pointsDTO = try req.content.decode([WarehousePointsDTO].self)
        let models = pointsDTO.map { $0.toModel() }
        try await models.create(on: req.db)
        return models.map { $0.toDTO() }
    }
    @Sendable
    func update(req: Request) async throws -> WarehousePointsDTO {
      guard let warehouse_points = try await WarehousePointsModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
          throw Abort(.notFound)
      }
        
        let updatedData = try req.content.decode(WarehousePointsDTO.self)
            
        if let name_points = updatedData.name_points {
            warehouse_points.name_points = name_points
        }
        if let pos_x = updatedData.pos_x {
            warehouse_points.pos_x = pos_x
        }
        if let pos_y = updatedData.pos_y {
            warehouse_points.pos_y = pos_y
        }
        
        if let id_warehouse = updatedData.id_warehouse {
            warehouse_points.id_warehouse = id_warehouse
        }

        try await warehouse_points.update(on: req.db)
        return warehouse_points.toDTO()
    }
        

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let warehouse_point = try await WarehousePointsModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await WarehouseEdgeModel.query(on: req.db)
            .filter(\.$id_points_to == warehouse_point.id!.uuidString)
            .filter(\.$id_points_from == warehouse_point.id!.uuidString)
            .delete()

        try await warehouse_point.delete(on: req.db)
        return .noContent
    }
}

