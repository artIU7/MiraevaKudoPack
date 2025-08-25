import Fluent

struct CreateAPIDataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("api_data")
            .id()
            .field("name",            .string, .required)
            .field("baseURL",         .string, .required)
            .field("endpoint",        .string, .required)
            .field("method",          .string, .required)
            .field("description",     .string, .required)
            .field("requestExample",  .string, .required)
            .field("responseExample", .string, .required)
            .field("headers",         .string, .required)
            .field("queryParameters", .string, .required)
            .field("pathParameters",  .string, .required)
            .field("category",        .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("api_data").delete()
    }
}
