//
//  OrderDataDTO.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct OrderDataDTO: Content {
    var id: UUID?
    var id_order_item   : String?     // ID заказа
    var id_box          : String?     // ID коробки
    var name_box        : String?     // имя коробки
    var count_box       : Int?        // количество коробок

    func toModel() -> OrderDataModel {
        let model = OrderDataModel()
        
        model.id = self.id

        if let id_order_item = self.id_order_item {
            model.id_order_item = id_order_item
        }
        
        if let id_box = self.id_box {
            model.id_box = id_box
        }
        
        if let name_box = self.name_box {
            model.name_box = name_box
        }
        
        if let count_box = self.count_box {
            model.count_box = count_box
        }
        
        return model
    }
}
