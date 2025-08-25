//
//  OrderPakingParamModel.swift
//
//
//  Created by Артем Стратиенко on 29.03.2025.
//

import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class OrderPakingParamModel: Model, @unchecked Sendable {
    static let schema = "order_param"
    // [ 0 ]
    // UUID - параметры
    @ID(key: .id)
    var id: UUID?
    // [ 1 ]
    // id_order - ID заказа на складе
    @Field(key: "id_order_item")
    var id_order_item: String
    // [ 2 ]
    // pallet_width - ширина паллеты в заказе
    @Field(key: "pallet_width")
    var pallet_width: Int
    // [ 3 ]
    // pallet_length - длина паллеты в заказе
    @Field(key: "pallet_length")
    var pallet_length: Int
    // [ 4 ]
    // pallet_max_height - высота допустимая паллеты собранной в заказе
    @Field(key: "pallet_max_height")
    var pallet_max_height: Int
    // [ 6 ]
    // min_support_ratio -  Минимальная площадь опоры для коробок размещаемых выше первого слоя ( % )
    @Field(key: "min_support_ratio")
    var min_support_ratio: Double
    // [ 7 ]
    // min_layer_fill_ratio -  Минимальное перекрытие слоя коробками ( % )
    @Field(key: "min_layer_fill_ratio")
    var min_layer_fill_ratio: Double
    // [ 8 ]
    // height_tolerance -  Перепад высоты слоя ( см )
    @Field(key: "height_tolerance")
    var height_tolerance: Double
    // [ 9 ]
    // height_layer_diff -  Разные высоты в слое
    @Field(key: "height_layer_diff")
    var height_layer_diff: Int
    // [ 10 ]
    // packing_type -  Тип упаковкм
    @Field(key: "packing_type")
    var packing_type: Int

    init() { }

    init(id: UUID? = nil,
         id_order_item: String,
         pallet_width: Int,
         pallet_length:Int,
         pallet_max_height:Int,
         min_support_ratio: Double,
         min_layer_fill_ratio: Double,
         height_tolerance: Double,
         height_layer_diff:Int,
         packing_type:Int
        )
    {
        self.id = id
        self.id_order_item = id_order_item
        self.pallet_width = pallet_width
        self.pallet_length = pallet_length
        self.pallet_max_height = pallet_max_height
        self.min_support_ratio = min_support_ratio
        self.min_layer_fill_ratio = min_layer_fill_ratio
        self.height_tolerance = height_tolerance
        self.height_layer_diff = height_layer_diff
        self.packing_type = packing_type

    }
    
    func toDTO() -> OrderPakingParamDTO {
        .init(
            id:                     self.id,
            id_order_item:          self.$id_order_item.value,
            pallet_width:           self.$pallet_width.value,
            pallet_length:          self.$pallet_length.value,
            pallet_max_height:      self.$pallet_max_height.value,
            min_support_ratio:      self.$min_support_ratio.value,
            min_layer_fill_ratio:   self.$min_layer_fill_ratio.value,
            height_tolerance:       self.$height_tolerance.value,
            height_layer_diff:      self.$height_layer_diff.value,
            packing_type:           self.$packing_type.value
        )
    }
}

