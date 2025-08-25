//
//  WarehousePointsDTO.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehousePointsDTO: Content {
    var id: UUID?
    var name_points     : String?     // Название точки
    var pos_x           : Int?        // Позиция точки pos_x
    var pos_y           : Int?        // Позиция точки pos_y
    var id_warehouse    : String?     // ID склада

    
    func toModel() -> WarehousePointsModel {
        let model = WarehousePointsModel()
        
        model.id = self.id

        if let name_points = self.name_points {
            model.name_points = name_points
        }
        
        if let pos_x = self.pos_x {
            model.pos_x = pos_x
        }
        
        if let pos_y = self.pos_y {
            model.pos_y = pos_y
        }
        
        if let id_warehouse = self.id_warehouse {
            model.id_warehouse = id_warehouse
        }
        
        return model
    }
}
