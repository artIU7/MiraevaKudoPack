//
//  CreateWarehouseSectionMigration.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateWarehouseSectionMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("warehouse_section")
            .id()
            .field("section_name",  .string, .required)
            .field("sku_name",      .string, .required)
            .field("count_box",     .int, .required)
            .field("id_box",        .string, .required)
            .field("id_warehouse",  .string, .required)
            //.unique(on: "section_name")
            // внутри контроллера добавиь проверку на существования секции с переданным именем в рамках одного склада
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("warehouse_data").delete()
    }
}
