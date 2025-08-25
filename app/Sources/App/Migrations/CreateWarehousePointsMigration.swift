//
//  CreateWarehousePointsMigration.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateWarehousePointsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("warehouse_points")
            .id()
            .field("name_points",   .string, .required)
            .field("pos_x",         .int, .required)
            .field("pos_y",         .int, .required)
            .field("id_warehouse",  .string, .required)
            .unique(on: "name_points")
            // внутри контроллера добавиь проверку на существования точки с переданным именем в рамках одного склада
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("warehouse_points").delete()
    }
}
