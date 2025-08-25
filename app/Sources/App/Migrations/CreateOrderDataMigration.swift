//
//  CreateOrderDataMigration.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateOrderDataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("order_data")
            .id()
            .field("id_order_item", .string, .required)
            .field("id_box",        .string, .required)
            .field("name_box",      .string, .required)
            .field("count_box",     .int, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("order_data").delete()
    }
}
