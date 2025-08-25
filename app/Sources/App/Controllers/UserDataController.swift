//
//  UserDataController.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

// Для ответа с данными пользователя без пароля
struct UserPublicResponse: Content {
    let id: UUID
    let user_login: String
    let user_fio: String
    let role: Int
    let warehouseId: String
}

struct UserDataController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let user_data = routes.grouped("user_data")

        // Обработка OPTIONS для /user_data/login
        user_data.on(.OPTIONS, "login", use: { req -> HTTPStatus in
            return .ok
        })
        user_data.get(use: self.index)
        // Маршрут для получения пользователей по warehouseId
        user_data.get("withWarehouseID", ":warehouseId", use: self.withWHID)
        user_data.post(use: self.create)
        user_data.group(":user_dataID") { user_data_selected in
            user_data_selected.put(use: self.update)
            user_data_selected.delete(use: self.delete)
        }
        // Авторизация юзера
        let authenticated = user_data.grouped(UserBasicAuthenticator())
        authenticated.post("login", use: self.login)
    }
    @Sendable
    func withWHID(req: Request) async throws -> [UserDataDTO] {
        guard let warehouseId = req.parameters.get("warehouseId") else {
            throw Abort(.badRequest, reason: "Missing warehouseId parameter")
        }
        
        let users = try await UserDataModel.query(on: req.db)
            .filter(\.$uuid_warehouse == warehouseId)
            .all()
        
        return users.map { $0.toDTO() }
    }
    @Sendable
    func index(req: Request) async throws -> [UserDataDTO] {
        try await UserDataModel.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> UserDataDTO {
        let user_data = try req.content.decode(UserDataDTO.self).toModel()

        try await user_data.save(on: req.db)
        return user_data.toDTO()
    }
    @Sendable
    func update(req: Request) async throws -> UserDataDTO {
      guard let user_data = try await UserDataModel.find(req.parameters.get("user_dataID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedData = try req.content.decode(UserDataDTO.self)
        
      if let user_login = updatedData.user_login {
          user_data.user_login = user_login
      }
    
      if let user_fio = updatedData.user_fio {
          user_data.user_fio = user_fio
      }
        
      if let user_password = updatedData.user_password {
          user_data.user_password = try Bcrypt.hash(user_password)
      }
      if let uuid_warehouse = updatedData.uuid_warehouse {
          user_data.uuid_warehouse = uuid_warehouse
      }
      if let user_role = updatedData.user_role {
          user_data.user_role = user_role
      }

      try await user_data.update(on: req.db)
      
      return user_data.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let user_data = try await UserDataModel.find(req.parameters.get("user_dataID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await user_data.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func login(req: Request) async throws -> UserPublicResponse {
        let user = try await req.auth.require(UserDataModel.self)
        return UserPublicResponse(
            id: try user.requireID(),
            user_login: user.user_login,
            user_fio: user.user_fio,
            role: user.user_role,
            warehouseId: user.uuid_warehouse
        )
    }
}
