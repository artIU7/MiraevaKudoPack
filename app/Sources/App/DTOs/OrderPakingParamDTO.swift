//
//  OrderPakingParamDTO.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import Vapor

struct OrderPakingParamDTO: Content {
        var id: UUID?
        var id_order_item: String?        // ID заказа
        var pallet_width: Int?            // ширина паллеты
        var pallet_length:Int?            // длина паллеты
        var pallet_max_height:Int?        // макс высота паллеты в сборе
        var min_support_ratio: Double?    // макс площадь опоры коробки над нижним слоем
        var min_layer_fill_ratio: Double? // макс заполнение слоя
        var height_tolerance: Double?     // макс перепад высот в слое
        var height_layer_diff: Int?       // !!! собираем слой разной высоты
        var packing_type: Int?            // !!! собираем слой по углу паллет


    func toModel() -> OrderPakingParamModel {
        let model = OrderPakingParamModel()
        
        model.id = self.id

        if let id_order_item = self.id_order_item {
            model.id_order_item = id_order_item
        }
        
        if let pallet_width = self.pallet_width {
            model.pallet_width = pallet_width
        }
        
        if let pallet_length = self.pallet_length {
            model.pallet_length = pallet_length
        }
        
        if let pallet_max_height = self.pallet_max_height {
            model.pallet_max_height = pallet_max_height
        }
        
        if let min_support_ratio = self.min_support_ratio {
            model.min_support_ratio = min_support_ratio
        }
        
        if let min_layer_fill_ratio = self.min_layer_fill_ratio {
            model.min_layer_fill_ratio = min_layer_fill_ratio
        }
        
        if let height_tolerance = self.height_tolerance {
            model.height_tolerance = height_tolerance
        }
        
        if let height_layer_diff = self.height_layer_diff {
            model.height_layer_diff = height_layer_diff
        }
        
        if let packing_type = self.packing_type {
            model.packing_type = packing_type
        }
        
        return model
    }
}
