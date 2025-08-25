//
//  UserDataDTO.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct UserDataDTO: Content {
    var id: UUID?
    var user_login      : String?     // Логин пользователя
    var user_fio        : String?     // Фио пользователя
    var user_password   : String?     // Пароль пользователя
    var uuid_warehouse  : String?     // ID склада
    var user_role       : Int?        // Роль пользователя
    
    func toModel() throws -> UserDataModel {
        let model = UserDataModel()
        
        model.id = self.id

        if let user_login = self.user_login {
            model.user_login = user_login
        }
        
        if let user_fio = self.user_fio {
            model.user_fio = user_fio
        }
        
        if let user_password = self.user_password {
            model.user_password = try Bcrypt.hash(user_password)
        }
        
        if let uuid_warehouse = self.uuid_warehouse {
            model.uuid_warehouse = uuid_warehouse
        }
        
        if let user_role = self.user_role {
            model.user_role = user_role
        }
        
        return model
    }
}
