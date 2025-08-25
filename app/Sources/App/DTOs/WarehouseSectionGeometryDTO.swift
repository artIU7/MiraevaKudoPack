//
//  WarehouseSectionGeometryDTO.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct  WarehouseSectionGeometryDTO: Content {
    var id: UUID?
    var name_section            : String?     // Название секции
    var id_warehouse_section    : String?     // ID секции
    var id_warehouse            : String?     // ID склада
    var name_point_way          : String?     // Название точки графа
    var id_point_way            : String?     // ID точки графа
    var x_pos                   : Int?        // x_pos секции
    var y_pos                   : Int?        // y_pos секции
    var widht_wsec              : Int?        // widht_wsec секции
    var lenght_wsec             : Int?        // lenght_wsec секции

    
    func toModel() -> WarehouseSectionGeometryModel {
        let model = WarehouseSectionGeometryModel()
        
        model.id = self.id

        if let name_section = self.name_section {
            model.name_section = name_section
        }
        
        if let id_warehouse_section = self.id_warehouse_section {
            model.id_warehouse_section = id_warehouse_section
        }
        
        if let id_warehouse = self.id_warehouse {
            model.id_warehouse = id_warehouse
        }
        
        if let name_point_way = self.name_point_way {
            model.name_point_way = name_point_way
        }
        
        if let id_point_way = self.id_point_way {
            model.id_point_way = id_point_way
        }
        
        if let x_pos = self.x_pos {
            model.x_pos = x_pos
        }
        
        if let y_pos = self.y_pos {
            model.y_pos = y_pos
        }
        
        if let widht_wsec = self.widht_wsec {
            model.widht_wsec = widht_wsec
        }
        
        if let lenght_wsec = self.lenght_wsec {
            model.lenght_wsec = lenght_wsec
        }
        
        return model
    }
}
