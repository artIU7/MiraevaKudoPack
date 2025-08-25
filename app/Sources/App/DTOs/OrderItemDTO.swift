//
//  OrderItemDTO.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct OrderItemDTO: Content {
    var id: UUID?
    var id_warehouse   : String?     // ID склада
    var order_name     : String?     // Название заказа
    var pallete_computed : Data?
    
    func toModel() -> OrderItemModel {
        let model = OrderItemModel()
        
        model.id = self.id

        if let id_warehouse = self.id_warehouse {
            model.id_warehouse = id_warehouse
        }
        
        if let order_name = self.order_name {
            model.order_name = order_name
        }
        
        if let pallete_computed = self.pallete_computed {
            model.pallete_computed = pallete_computed
        }
        
        return model
    }
}
