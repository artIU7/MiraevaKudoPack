import Fluent

struct CreateKudoBoxMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("kudobox")
            .id()
            .field("sku_box",           .string, .required)
            .field("width_box",         .int, .required)
            .field("length_box",        .int, .required)
            .field("height_box",        .int, .required)
            .field("weight_box",        .int, .required)
            .field("is_rotated_box",    .int, .required)
            .field("max_load_box",      .int, .required)
            .field("uuid_warehouse",    .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("kudobox").delete()
    }
}
