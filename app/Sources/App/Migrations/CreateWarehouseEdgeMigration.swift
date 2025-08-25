//
//  CreateWarehouseEdgeMigration.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateWarehouseEdgeMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("warehouse_edge")
            .id()
            .field("name_points_from",  .string, .required)
            .field("name_points_to",    .string, .required)
            .field("id_points_from",    .string, .required)
            .field("id_points_to",      .string, .required)
            .field("id_warehouse",      .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("warehouse_edge").delete()
    }
}
