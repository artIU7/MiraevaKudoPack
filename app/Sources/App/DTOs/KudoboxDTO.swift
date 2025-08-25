import Fluent
import Vapor

struct KudoboxDTO: Content {
    var id: UUID?
    var sku_box: String?         // sku номер на складе
    var width_box  : Int?        // ширина коробки
    var length_box : Int?        // длина коробки
    var height_box : Int?        // высота коробки
    var weight_box : Int?        // вес коробки
    var is_rotated_box : Int?    // 1 - можно вращать, 0 - нельзя
    var max_load_box : Int?      // Максимальная нагрузка сверху
    var uuid_warehouse : String? // UUID Склада

    
    func toModel() -> KudoboxModel {
        let model = KudoboxModel()
        
        model.id = self.id

        if let sku_box = self.sku_box {
            model.sku_box = sku_box
        }
        
        if let width_box = self.width_box {
            model.width_box = width_box
        }
        
        if let length_box = self.length_box {
            model.length_box = length_box
        }
        
        if let height_box = self.height_box {
            model.height_box = height_box
        }
        
        if let weight_box = self.weight_box {
            model.weight_box = weight_box
        }
        
        if let is_rotated_box = self.is_rotated_box {
            model.is_rotated_box = is_rotated_box
        }
        
        if let max_load_box = self.max_load_box {
            model.max_load_box = max_load_box
        }
        
        if let uuid_warehouse = self.uuid_warehouse {
            model.uuid_warehouse = uuid_warehouse
        }
        
        return model
    }
}
