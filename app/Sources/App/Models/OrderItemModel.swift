//
//  OrderItemModel.swift
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
final class OrderItemModel: Model, @unchecked Sendable {
    static let schema = "order_item"
    // [ 0 ]
    // UUID - заказа
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // id_warehouse - ID склада
    @Field(key: "id_warehouse")
    var id_warehouse: String
    // [ 2 ]
    // order_name - название заказа
    @Field(key: "order_name")
    var order_name: String
    //[ 3]
    // расчет паллет
    @Field(key: "pallete_computed")
    var pallete_computed: Data

    init() { }

    init(id: UUID? = nil,
         id_warehouse: String,
         order_name : String,
         pallete_computed : Data
        )
    {
        self.id = id
        self.id_warehouse = id_warehouse
        self.order_name = order_name
        self.pallete_computed = pallete_computed
    }
    
    func toDTO() -> OrderItemDTO {
        .init(
            id:               self.id,
            id_warehouse:     self.$id_warehouse.value,
            order_name:       self.$order_name.value,
            pallete_computed: self.$pallete_computed.value
        )
    }
}
