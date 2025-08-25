//
//  OrderDataModel.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class OrderDataModel: Model, @unchecked Sendable {
    static let schema = "order_data"
    // [ 0 ]
    // UUID - заказа
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // id_order - ID заказа на складе
    @Field(key: "id_order_item")
    var id_order_item: String
    // [ 2 ]
    // id_box - ID коробки на складе
    @Field(key: "id_box")
    var id_box: String
    // [ 3 ]
    // name_box - Имя коробки на складе
    @Field(key: "name_box")
    var name_box: String
    // [ 3 ]
    // count_box - Количество коробок на складе
    @Field(key: "count_box")
    var count_box: Int


    init() { }

    init(id: UUID? = nil,
         id_order_item: String,
         id_box : String,
         name_box : String,
         count_box:Int
        )
    {
        self.id = id
        self.id_order_item = id_order_item
        self.id_box = id_box
        self.name_box = name_box
        self.count_box = count_box
    }
    
    func toDTO() -> OrderDataDTO {
        .init(
            id:              self.id,
            id_order_item:   self.$id_order_item.value,
            id_box:          self.$id_box.value,
            name_box:        self.$name_box.value,
            count_box:       self.$count_box.value
        )
    }
}
