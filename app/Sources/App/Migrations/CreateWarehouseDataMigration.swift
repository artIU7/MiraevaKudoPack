//
//  CreateWarehouseDataMigration.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateWarehouseDataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("warehouse_data")
            .id()
            .field("warehouse_name",  .string, .required)
            .field("warehouse_width", .int, .required)
            .field("warehouse_length",.int, .required)
            .unique(on: "warehouse_name")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("warehouse_data").delete()
    }
}
