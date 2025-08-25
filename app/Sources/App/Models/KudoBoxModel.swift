import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class KudoboxModel: Model, @unchecked Sendable {
    static let schema = "kudobox"
    // [ 0 ]
    // UUID
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // sku номер на складе
    @Field(key: "sku_box")
    var sku_box: String
    // [ 2 ]
    // ширина коробки
    @Field(key: "width_box")
    var width_box: Int
    // [ 3 ]
    // длина коробки
    @Field(key: "length_box")
    var length_box: Int
    // [ 4 ]
    // высота коробки
    @Field(key: "height_box")
    var height_box: Int
    // [ 5 ]
    // вес коробки
    @Field(key: "weight_box")
    var weight_box: Int
    // [ 6 ]
    // Флаг вращения коробки
    // 1 - можно вращать, 0 - нельзя
    @Field(key: "is_rotated_box")
    var is_rotated_box: Int
    // [ 7 ]
    // Максимальная нагрузка сверху
    @Field(key: "max_load_box")
    var max_load_box: Int
    // [ 8 ]
    // UUID Склада
    @Field(key: "uuid_warehouse")
    var uuid_warehouse: String
    

    init() { }

    init(id: UUID? = nil,
         sku_box: String,
         width_box : Int,
         length_box: Int,
         height_box: Int,
         weight_box: Int,
         is_rotated_box: Int,
         max_load_box: Int,
         uuid_warehouse: String
        )
    {
        self.id = id
        self.sku_box = sku_box
        self.width_box = width_box
        self.length_box = length_box
        self.height_box = height_box
        self.weight_box = weight_box
        self.is_rotated_box = is_rotated_box
        self.max_load_box = max_load_box
        self.uuid_warehouse = uuid_warehouse

    }
    
    func toDTO() -> KudoboxDTO {
        .init(
            id:             self.id,
            sku_box:        self.$sku_box.value,
            width_box:      self.$width_box.value,
            length_box:     self.$length_box.value,
            height_box:     self.$height_box.value,
            weight_box:     self.$weight_box.value,
            is_rotated_box: self.$is_rotated_box.value,
            max_load_box:   self.$max_load_box.value,
            uuid_warehouse: self.$uuid_warehouse.value
        )
    }
}
