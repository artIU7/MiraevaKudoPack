//
//  WarehousePointsModel.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class WarehousePointsModel: Model, @unchecked Sendable {
    static let schema = "warehouse_points"
    // [ 0 ]
    // UUID - точки на складе
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // name_points - название точки
    @Field(key: "name_points")
    var name_points: String
    // [ 2 ]
    // pos_x - x pos точки
    @Field(key: "pos_x")
    var pos_x: Int
    // [ 3 ]
    // pos_y - y pos точки
    @Field(key: "pos_y")
    var pos_y: Int
    // [ 4 ]
    // id_warehouse - ID склада
    @Field(key: "id_warehouse")
    var id_warehouse: String

    init() { }

    init(id: UUID? = nil,
         name_points: String,
         pos_x : Int,
         pos_y : Int,
         id_warehouse: String
        )
    {
        self.id = id
        self.name_points = name_points
        self.pos_x = pos_x
        self.pos_y = pos_y
        self.id_warehouse = id_warehouse
    }
    
    func toDTO() -> WarehousePointsDTO {
        .init(
            id:                   self.id,
            name_points:          self.$name_points.value,
            pos_x:                self.$pos_x.value,
            pos_y:                self.$pos_y.value,
            id_warehouse:         self.$id_warehouse.value
        )
    }
}
