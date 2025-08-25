//
//  CreateOrderPakingParamMigration.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent

struct CreateOrderPakingParamMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("order_param")
            .id()
            .field("id_order_item",         .string, .required)
            .field("pallet_width",          .int,    .required)
            .field("pallet_length",         .int,    .required)
            .field("pallet_max_height",     .int,    .required)
            .field("min_support_ratio",     .double, .required)
            .field("min_layer_fill_ratio",  .double, .required)
            .field("height_tolerance",      .double, .required)
            .field("height_layer_diff",     .int,    .required)
            .field("packing_type",          .int,    .required)
            .unique(on: "id_order_item")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("order_param").delete()
    }
}
