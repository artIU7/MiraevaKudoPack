//
//  WarehouseSectionDTO.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct WarehouseSectionDTO: Content {
    var id: UUID?
    var section_name    : String?     // Название секции
    var sku_name        : String?     // SKU коробки
    var count_box       : Int?        // Количество коробок
    var id_box          : String?     // ID коробки
    var id_warehouse    : String?     // ID склада

    
    func toModel() -> WarehouseSectionModel {
        let model = WarehouseSectionModel()
        
        model.id = self.id

        if let section_name = self.section_name {
            model.section_name = section_name
        }
        
        if let sku_name = self.sku_name {
            model.sku_name = sku_name
        }
        
        if let count_box = self.count_box {
            model.count_box = count_box
        }
        
        if let id_box = self.id_box {
            model.id_box = id_box
        }
        
        if let id_warehouse = self.id_warehouse {
            model.id_warehouse = id_warehouse
        }
        
        return model
    }
}
