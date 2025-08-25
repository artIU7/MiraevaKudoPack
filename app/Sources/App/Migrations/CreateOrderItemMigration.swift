//
//  CreateOrderItemMigration.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateOrderItemMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("order_item")
            .id()
            .field("id_warehouse",     .string, .required)
            .field("order_name",       .string, .required)
            .field("pallete_computed", .data,   .required)
            .unique(on: "order_name")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("order_item").delete()
    }
}
