import Fluent
import Vapor

struct APIDataController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("api_data")

        api.get(use: self.index)
        api.get("apiID", ":apiID", use: self.apiWithID)
        api.post(use: self.create)
        api.group(":apiID") { apiSelected in
            apiSelected.put(use: self.update)
            apiSelected.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [APIDataDTO] {
        try await APIDataModel.query(on: req.db).all().map { $0.toDTO() }
    }
    
   @Sendable
    func apiWithID(req: Request) async throws -> APIDataDTO {
        guard let apiIDString = req.parameters.get("apiID") else {
            throw Abort(.badRequest, reason: "Missing apiID parameter")
        }
        guard let apiID = UUID(apiIDString) else {
            throw Abort(.badRequest, reason: "Invalid apiID format - must be UUID")
        }
        guard let api = try await APIDataModel.query(on: req.db)
            .filter(\.$id == apiID)
            .first() else {
                throw Abort(.notFound, reason: "API not found")
        }    
        return api.toDTO()
    }
    @Sendable
    func create(req: Request) async throws -> APIDataDTO {
        let api_data = try req.content.decode(APIDataDTO.self)
        try await api_data.toModel().save(on: req.db)
        return api_data.toModel().toDTO()
    }
    
    @Sendable
    func update(req: Request) async throws -> APIDataDTO {
      guard let api = try await APIDataModel.find(req.parameters.get("apiID"), on: req.db) else {
          throw Abort(.notFound)
      }
      let updatedApi = try req.content.decode(APIDataDTO.self)
        
        if let name = updatedApi.name {
            api.name = name
        }
        if let baseURL = updatedApi.baseURL {
            api.baseURL = baseURL
        }
        if let endpoint = updatedApi.endpoint {
            api.endpoint = endpoint
        }
        if let method = updatedApi.method {
            api.method = method
        }
        if let description = updatedApi.description {
            api.description = description
        }
        if let requestExample = updatedApi.requestExample {
            api.requestExample = requestExample
        }
        if let responseExample = updatedApi.responseExample {
            api.responseExample = responseExample
        }
        if let headers = updatedApi.headers {
            api.headers = headers
        }
        if let queryParameters = updatedApi.queryParameters {
            api.queryParameters = queryParameters
        }
        if let pathParameters = updatedApi.pathParameters {
            api.pathParameters = pathParameters
        }
        if let category = updatedApi.category {
            api.category = category
        }

      try await api.update(on: req.db)
      return api.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let api = try await APIDataModel.find(req.parameters.get("apiID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await api.delete(on: req.db)
        return .noContent
    }
}
