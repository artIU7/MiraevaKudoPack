//
//  WarehouseDataModel.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class WarehouseDataModel: Model, @unchecked Sendable {
    static let schema = "warehouse_data"
    // [ 0 ]
    // UUID - склада
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // warehouse_name - название склада
    @Field(key: "warehouse_name")
    var warehouse_name: String
    // [ 2 ]
    // warehouse_width - ширина склада
    @Field(key: "warehouse_width")
    var warehouse_width: Int
    // [ 3 ]
    // warehouse_length - длина склада
    @Field(key: "warehouse_length")
    var warehouse_length: Int

    init() { }

    init(id: UUID? = nil,
         warehouse_name: String,
         warehouse_width : Int,
         warehouse_length: Int
        )
    {
        self.id = id
        self.warehouse_name = warehouse_name
        self.warehouse_width = warehouse_width
        self.warehouse_length = warehouse_length
    }
    
    func toDTO() -> WarehouseDataDTO {
        .init(
            id:                   self.id,
            warehouse_name:       self.$warehouse_name.value,
            warehouse_width:      self.$warehouse_width.value,
            warehouse_length:     self.$warehouse_length.value
        )
    }
}
