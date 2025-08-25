//
//  CreateUserDataMigration.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor


struct CreateUserDataMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user_data")
            .id()
            .field("user_login",    .string, .required)
            .field("user_fio",      .string, .required)
            .field("user_password", .string, .required)
            .field("uuid_warehouse",.string, .required)
            .field("user_role",     .int, .required)
            .unique(on: "user_login")
            .create()
             
             // Создаем пользователя admin
             let  adminUser = try UserDataModel(
                  id :nil,
                  user_login: "admin",
                  user_fio: "Администратор",
                  user_password: "admin",
                  uuid_warehouse: "",
                  user_role: 1
             )
             
             // Сохраняем пользователя в базу данных
             try await adminUser.create(on: database)
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user_data").delete()
    }
}
