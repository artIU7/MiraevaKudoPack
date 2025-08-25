//
// WarehouseSectionController.swift
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehouseSectionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let warehouse_section = routes.grouped("warehouse_section")

        warehouse_section.get(use: self.index)
        // Маршрут для получения коробок по warehouseId
        warehouse_section.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        warehouse_section.post(use: self.create)
        warehouse_section.post("sections",use: self.createArray)
        warehouse_section.put("withWarehouseID", ":warehouseId","withBoxID", ":boxId","withCountBox", ":countBox", use: self.orderGetBox)

        warehouse_section.group(":warehouse_sectionID") { warehouse_section_selected in
            warehouse_section_selected.put(use: self.update)
            warehouse_section_selected.delete(use: self.delete)
        }
        
    }

    @Sendable
    func index(req: Request) async throws -> [WarehouseSectionDTO] {
        try await WarehouseSectionModel.query(on: req.db).all().map { $0.toDTO() }
    }
    
    @Sendable
    func withWHID(req: Request) async throws -> [WarehouseSectionDTO] {
        guard let warehouseId = req.parameters.get("warehouseId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        
        let section = try await WarehouseSectionModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .all()
        
        return section.map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> WarehouseSectionDTO {
        let section_data = try req.content.decode(WarehouseSectionDTO.self)
        if let sectionData = try await WarehouseSectionModel.query(on: req.db )
            .filter(\.$section_name == section_data.section_name!)
            .filter(\.$id_warehouse == section_data.id_warehouse!)
            .first() {
            throw Abort(.badRequest, reason: "Секция уже существует !")
            //return sectionData.toDTO()
        } else {
            try await section_data.toModel().save(on: req.db)
            return section_data.toModel().toDTO()
        }
    }
    @Sendable
    func createArray(req: Request) async throws -> [WarehouseSectionDTO] {
        let sectionDTO = try req.content.decode([WarehouseSectionDTO].self)
        var results: [WarehouseSectionDTO] = []
    
        for dto in sectionDTO {
            if let sectionData = try await WarehouseSectionModel.query(on: req.db)
                .filter(\.$section_name == dto.section_name!)
                .filter(\.$id_warehouse == dto.id_warehouse!)
                .first() {
                results.append(sectionData.toDTO())
            } else {
            let model = dto.toModel()
            try await model.save(on: req.db)
            results.append(model.toDTO())
            }
        }
        return results
    }

    @Sendable
    func update(req: Request) async throws -> WarehouseSectionDTO {
      guard let warehouse_section = try await WarehouseSectionModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedData = try req.content.decode(WarehouseSectionDTO.self)
        if let section_name = updatedData.section_name {
            warehouse_section.section_name = section_name
        }
        if let sku_name = updatedData.sku_name {
            warehouse_section.sku_name = sku_name
        }
        if let count_box = updatedData.count_box {
            warehouse_section.count_box = count_box
        }
        if let id_box = updatedData.id_box {
            warehouse_section.id_box = id_box
        }
        if let id_warehouse = updatedData.id_warehouse {
            warehouse_section.id_warehouse = id_warehouse
        }
      try await warehouse_section.update(on: req.db)      
      return warehouse_section.toDTO()
    }
    
    @Sendable
    func orderGetBox(req: Request) async throws -> WarehouseSectionDTO {
        guard
            let warehouseId = req.parameters.get("warehouseId"),
            let boxID = req.parameters.get("boxId"),
            let count = req.parameters.get("countBox")
        else {
            throw Abort(.badRequest, reason: "Missing required parameters")
        }
        guard let section_box = try await WarehouseSectionModel.query(on: req.db)
            .filter(\.$id_warehouse == warehouseId)
            .filter(\.$id_box == boxID)
            .first()
         else {
            throw Abort(.notFound)
        }
        section_box.count_box -= Int(count)!
        try await section_box.update(on: req.db)
        return section_box.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let warehouse_section = try await WarehouseSectionModel.find(req.parameters.get("warehouse_sectionID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await WarehouseSectionGeometryModel.query(on: req.db)
            .filter(\.$id_warehouse_section == warehouse_section.id!.uuidString)
            .all()

        try await warehouse_section.delete(on: req.db)
        return .noContent
    }
}

