//
//  CreateWarehouseSectionGeometryMigration.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateWarehouseSectionGeometryMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("warehouse_section_geometry")
            .id()
            .field("name_section",          .string, .required)
            .field("id_warehouse_section",  .string, .required)
            .field("id_warehouse",          .string, .required)
            .field("name_point_way",        .string, .required)
            .field("id_point_way",          .string, .required)
            .field("x_pos",                 .int, .required)
            .field("y_pos",                 .int, .required)
            .field("widht_wsec",            .int, .required)
            .field("lenght_wsec",           .int, .required)
            //.unique(on: "name_section")
            // внутри контроллера добавиь проверку на существования геометрии секции с переданным именем в рамках одного склада
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("warehouse_section_geometry").delete()
    }
}
