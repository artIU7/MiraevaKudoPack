//
// WarehouseSectionGeometryController.swift
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehouseSectionGeometryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let warehouse_section_geometry = routes.grouped("warehouse_section_geometry")

        warehouse_section_geometry.get(use: self.index)
        // Маршрут для получения секций по warehouseId
        warehouse_section_geometry.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        warehouse_section_geometry.post(use: self.create)
        warehouse_section_geometry.post("sections",use: self.createArray)

        warehouse_section_geometry.group(":warehouse_sectionID") { warehouse_section_selected in
            warehouse_section_selected.put(use: self.update)
            warehouse_section_selected.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [WarehouseSectionGeometryDTO] {
        try await WarehouseSectionGeometryModel.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func withWHID(req: Request) async throws -> [WarehouseSectionGeometryDTO] {
        guard let warehouseId = req.parameters.get("warehouseId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        let section_geometry = try await WarehouseSectionGeometryModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .all()
        
        return section_geometry.map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> WarehouseSectionGeometryDTO {
        let warehouse_section = try req.content.decode(WarehouseSectionGeometryDTO.self).toModel()
        try await warehouse_section.save(on: req.db)
        return warehouse_section.toDTO()
    }
    @Sendable
    func createArray(req: Request) async throws -> [WarehouseSectionGeometryDTO] {
        let sectionsDTO = try req.content.decode([WarehouseSectionGeometryDTO].self)
        let models = sectionsDTO.map { $0.toModel() }
        try await models.create(on: req.db)
        return models.map { $0.toDTO() }
    }
    @Sendable
    func update(req: Request) async throws -> WarehouseSectionGeometryDTO {
      guard let warehouse_section = try await WarehouseSectionGeometryModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedData = try req.content.decode(WarehouseSectionGeometryDTO.self)
        if let name_section = updatedData.name_section {
            warehouse_section.name_section = name_section
        }
        if let id_warehouse_section = updatedData.id_warehouse_section {
            warehouse_section.id_warehouse_section = id_warehouse_section
        }
        if let id_warehouse = updatedData.id_warehouse {
            warehouse_section.id_warehouse = id_warehouse
        }
        if let name_point_way = updatedData.name_point_way {
            warehouse_section.name_point_way = name_point_way
        }
        if let id_point_way = updatedData.id_point_way {
            warehouse_section.id_point_way = id_point_way
        }
        if let x_pos = updatedData.x_pos {
            warehouse_section.x_pos = x_pos
        }
        if let y_pos = updatedData.y_pos {
            warehouse_section.y_pos = y_pos
        }
        if let widht_wsec = updatedData.widht_wsec {
            warehouse_section.widht_wsec = widht_wsec
        }
        if let lenght_wsec = updatedData.lenght_wsec {
            warehouse_section.lenght_wsec = lenght_wsec
        }
      try await warehouse_section.update(on: req.db)
      return warehouse_section.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let warehouse_section = try await WarehouseSectionGeometryModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await warehouse_section.delete(on: req.db)
        return .noContent
    }
}

