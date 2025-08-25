//
//  WarehouseSectionGeometryModel.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class WarehouseSectionGeometryModel: Model, @unchecked Sendable {
    static let schema = "warehouse_section_geometry"
    // [ 0 ]
    // UUID - Geometry Section на складе
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // название секции
    @Field(key: "name_section")
    var name_section: String
    // [ 2 ]
    // id warehouse_section - название секции
    @Field(key: "id_warehouse_section")
    var id_warehouse_section: String
    // [ 3 ]
    // id warehouse - id склада
    @Field(key: "id_warehouse")
    var id_warehouse: String
    // [ 4 ]
    // name_point_way - название точки графа
    @Field(key: "name_point_way")
    var name_point_way: String
    // [ 5 ]
    // id_point_way - id точки графа
    @Field(key: "id_point_way")
    var id_point_way: String
    // [ 6 ]
    // x_pos - x_pos секции
    @Field(key: "x_pos")
    var x_pos: Int
    // [ 7 ]
    // y_pos - y_pos секции
    @Field(key: "y_pos")
    var y_pos: Int
    // [ 8 ]
    // widht_wsec - widht_wsec секции
    @Field(key: "widht_wsec")
    var widht_wsec: Int
    // [ 9 ]
    // lenght_wsec - lenght_wsec секции
    @Field(key: "lenght_wsec")
    var lenght_wsec: Int
    
    init() { }

    init(id: UUID? = nil,
         name_section:          String,
         id_warehouse_section:  String,
         id_warehouse:          String,
         name_point_way:        String,
         id_point_way:          String,
         x_pos :                Int,
         y_pos :                Int,
         widht_wsec :           Int,
         lenght_wsec :          Int
        )
    {
        self.id = id
        self.name_section = name_section
        self.id_warehouse_section = id_warehouse_section
        self.id_warehouse = id_warehouse
        self.name_point_way = name_point_way;
        self.id_point_way = id_point_way
        self.x_pos = x_pos
        self.y_pos = y_pos
        self.widht_wsec = widht_wsec
        self.lenght_wsec = lenght_wsec
    }
    
    func toDTO() -> WarehouseSectionGeometryDTO {
        .init(
            id:                   self.id,
            name_section:         self.$name_section.value,
            id_warehouse_section: self.$id_warehouse_section.value,
            id_warehouse:         self.$id_warehouse.value,
            name_point_way:       self.$name_point_way.value,
            id_point_way:         self.$id_point_way.value,
            x_pos:                self.$x_pos.value,
            y_pos:                self.$y_pos.value,
            widht_wsec:           self.$widht_wsec.value,
            lenght_wsec:          self.$lenght_wsec.value
        )
    }
}
