//
//  WarehouseDataDTO.swift
//  
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehouseDataDTO: Content {
    var id: UUID?
    var warehouse_name   : String?     // Название склада
    var warehouse_width  : Int?        // Ширина склада
    var warehouse_length : Int?        // Длина склада
    
    func toModel() -> WarehouseDataModel {
        let model = WarehouseDataModel()
        
        model.id = self.id

        if let warehouse_name = self.warehouse_name {
            model.warehouse_name = warehouse_name
        }
        
        if let warehouse_width = self.warehouse_width {
            model.warehouse_width = warehouse_width
        }
        
        if let warehouse_length = self.warehouse_length {
            model.warehouse_length = warehouse_length
        }
        
        return model
    }
}
