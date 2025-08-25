//
//  WarehouseEdgeDTO.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehouseEdgeDTO: Content {
    var id: UUID?
    var name_points_from     : String?     // Название точки От
    var name_points_to       : String?     // Название точки До
    var id_points_from       : String?     // ID точки От
    var id_points_to         : String?     // ID точки До
    var id_warehouse         : String?     // ID склада

    
    func toModel() -> WarehouseEdgeModel {
        let model = WarehouseEdgeModel()
        
        model.id = self.id

        if let name_points_from = self.name_points_from {
            model.name_points_from = name_points_from
        }
        
        if let name_points_to = self.name_points_to {
            model.name_points_to = name_points_to
        }
        
        if let name_points_from = self.name_points_from {
            model.name_points_from = name_points_from
        }
        
        if let id_points_from = self.id_points_from {
            model.id_points_from = id_points_from
        }
       
        if let id_points_to = self.id_points_to {
            model.id_points_to = id_points_to
        }
        
        if let id_warehouse = self.id_warehouse {
            model.id_warehouse = id_warehouse
        }
        
        return model
    }
}
