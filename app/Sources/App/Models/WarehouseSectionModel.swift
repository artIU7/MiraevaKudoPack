//
//  WarehouseSectionModel.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class WarehouseSectionModel: Model, @unchecked Sendable {
    static let schema = "warehouse_section"
    // [ 0 ]
    // UUID - секции на складе
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // section_name - название секции
    @Field(key: "section_name")
    var section_name: String
    // [ 2 ]
    // sku_name - название коробки
    @Field(key: "sku_name")
    var sku_name: String
    // [ 3 ]
    // count_box - количество коробок в секции
    @Field(key: "count_box")
    var count_box: Int
    // [ 4 ]
    // id_box - ID коробки
    @Field(key: "id_box")
    var id_box: String
    // [ 5 ]
    // id_warehouse - ID склада
    @Field(key: "id_warehouse")
    var id_warehouse: String

    init() { }

    init(id: UUID? = nil,
         section_name: String,
         sku_name: String,
         count_box : Int,
         id_box: String,
         id_warehouse: String
        )
    {
        self.id = id
        self.section_name = section_name
        self.sku_name = sku_name
        self.count_box = count_box
        self.id_box = id_box
        self.id_warehouse = id_warehouse
    }
    
    func toDTO() -> WarehouseSectionDTO {
        .init(
            id:                   self.id,
            section_name:         self.$section_name.value,
            sku_name:             self.$sku_name.value,
            count_box:            self.$count_box.value,
            id_box:               self.$id_box.value,
            id_warehouse:         self.$id_warehouse.value
        )
    }
}
