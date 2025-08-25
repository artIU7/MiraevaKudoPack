import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
// Models/APAPIDataModelI.swift

final class APIDataModel: Model, @unchecked Sendable {
    static let schema = "api_data"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "baseURL")
    var baseURL: String
    
    @Field(key: "endpoint")
    var endpoint: String
    
    @Field(key: "method")
    var method: String  
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "requestExample")
    var requestExample: String
    
    @Field(key: "responseExample")
    var responseExample: String
    
    @Field(key: "headers")
    var headers: String
    
    @Field(key: "queryParameters")
    var queryParameters: String
    
    @Field(key: "pathParameters")
    var pathParameters: String
    
    @Field(key: "category")
    var category: String
    
    init() {}
    
    init(id: UUID? = nil, 
         name: String, 
         baseURL: String, 
         endpoint: String, 
         method: String, 
         description: String, 
         requestExample: String, 
         responseExample: String, 
         headers: String, 
         queryParameters: String, 
         pathParameters: String, 
         category: String
         ) 
         {
            self.id = id
            self.name = name
            self.baseURL = baseURL
            self.endpoint = endpoint
            self.method = method
            self.description = description
            self.requestExample = requestExample
            self.responseExample = responseExample
            self.headers = headers
            self.queryParameters = queryParameters
            self.pathParameters = pathParameters
            self.category = category
    }
    func toDTO() -> APIDataDTO {
        .init(
            id              : self.id,
            name            : self.$name.value,
            baseURL         : self.$baseURL.value,
            endpoint        : self.$endpoint.value,
            method          : self.$method.value,
            description     : self.$description.value,
            requestExample  : self.$requestExample.value,
            responseExample : self.$responseExample.value,
            headers         : self.$headers.value,
            queryParameters : self.$queryParameters.value,
            pathParameters  : self.$pathParameters.value,
            category        : self.$category.value
        )
    }
}