import Fluent
import Vapor

struct APIDataDTO: Content {
    var id: UUID?
    var name: String? 
    var baseURL: String?
    var endpoint: String? 
    var method: String? 
    var description: String? 
    var requestExample: String? 
    var responseExample: String? 
    var headers: String?
    var queryParameters: String? 
    var pathParameters: String? 
    var category: String?
    
    func toModel() -> APIDataModel {
        let model = APIDataModel()
        
        model.id = self.id

        if let name = self.name {
            model.name = name
        }
        if let baseURL = self.baseURL {
            model.baseURL = baseURL
        }
        if let endpoint = self.endpoint {
            model.endpoint = endpoint
        }
        if let method = self.method {
            model.method = method
        }
        if let description = self.description {
            model.description = description
        }
        if let requestExample = self.requestExample {
            model.requestExample = requestExample
        }
        if let responseExample = self.responseExample {
            model.responseExample = responseExample
        }
        if let headers = self.headers {
            model.headers = headers
        }
        if let queryParameters = self.queryParameters {
            model.queryParameters = queryParameters
        }
        if let pathParameters = self.pathParameters {
            model.pathParameters = pathParameters
        }
        if let category = self.category {
            model.category = category
        }
        
        return model
    }
}
