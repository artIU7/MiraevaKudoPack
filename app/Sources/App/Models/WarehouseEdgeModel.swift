//
//  WarehouseEdgeModel.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class WarehouseEdgeModel: Model, @unchecked Sendable {
    static let schema = "warehouse_edge"
    // [ 0 ]
    // UUID - ребра на складе
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // name_points_from - название точки
    @Field(key: "name_points_from")
    var name_points_from: String
    // [ 2 ]
    // name_points_to - название точки
    @Field(key: "name_points_to")
    var name_points_to: String
    // [ 3 ]
    // id_points_from - id точки
    @Field(key: "id_points_from")
    var id_points_from: String
    // [ 4 ]
    // id_points_to - название точки
    @Field(key: "id_points_to")
    var id_points_to: String
    // [ 5 ]
    // id_warehouse - ID склада
    @Field(key: "id_warehouse")
    var id_warehouse: String

    init() { }

    init(id: UUID? = nil,
         name_points_from: String,
         name_points_to: String,
         id_points_from: String,
         id_points_to: String,
         id_warehouse: String
        )
    {
        self.id = id
        self.name_points_from   = name_points_from
        self.name_points_to     = name_points_to
        self.id_points_from     = id_points_from
        self.id_points_to       = id_points_to
        self.id_warehouse       = id_warehouse
    }
    
    func toDTO() -> WarehouseEdgeDTO {
        .init(
            id:                   self.id,
            name_points_from:     self.$name_points_from.value,
            name_points_to:       self.$name_points_to.value,
            id_points_from:       self.$id_points_from.value,
            id_points_to:         self.$id_points_to.value,
            id_warehouse:         self.$id_warehouse.value
        )
    }
}
