//
//  UserBasicAuthenticator.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct UserBasicAuthenticator: AsyncBasicAuthenticator {
    func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) async throws {
        guard let user = try await UserDataModel.query(on: request.db)
            .filter(\.$user_login == basic.username)
            .first() else {
            return
        }
        
        guard try Bcrypt.verify(basic.password, created: user.user_password) else {
            return
        }
        
        request.auth.login(user)
    }
}
