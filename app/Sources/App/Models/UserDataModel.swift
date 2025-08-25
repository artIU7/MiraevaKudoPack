//
//  UserDataModel.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class UserDataModel: Model,Authenticatable, @unchecked Sendable {
    static let schema = "user_data"
    // [ 0 ]
    // UUID - пользователя
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // user_login - Логин пользователя
    @Field(key: "user_login")
    var user_login: String
    // [ 2 ]
    // user_fio - фио пользователя
    @Field(key: "user_fio")
    var user_fio: String
    // [ 3 ]
    // user_password - пароль пользователя
    @Field(key: "user_password")
    var user_password: String
    // [ 4 ]
    // uuid_warehouse - ID склада
    @Field(key: "uuid_warehouse")
    var uuid_warehouse: String
    // [ 5 ]
    // user_role - роль пользователя
    @Field(key: "user_role")
    var user_role: Int

    init() { }

    init(id: UUID? = nil,
         user_login: String,
         user_fio: String,
         user_password : String,
         uuid_warehouse: String,
         user_role : Int
        )
    throws
    {
        self.id = id
        self.user_login = user_login
        self.user_fio = user_fio
        self.user_password = try Bcrypt.hash(user_password)
        self.uuid_warehouse = uuid_warehouse
        self.user_role = user_role
    }
    
    func toDTO() -> UserDataDTO {
        .init(
            id:                 self.id,
            user_login:         self.$user_login.value,
            user_fio:           self.$user_fio.value,
            user_password:      self.$user_password.value,
            uuid_warehouse:     self.$uuid_warehouse.value,
            user_role:          self.$user_role.value
        )
    }
}

extension UserDataModel: ModelAuthenticatable {
    static let usernameKey = \UserDataModel.$user_login
    static let passwordHashKey = \UserDataModel.$user_password

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.user_password)
    }
}
