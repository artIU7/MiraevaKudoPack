//
//  KudoBoxPackingOnPallete.swift
//  
//
//  Created by Артем Стратиенко on 01.04.2025.
//

import Foundation
import Fluent
import Vapor

struct PositionBox: Content {
    let x: Double
    let y: Double
}

struct BoxPallete: Content {
    var id: UUID
    var orderPrior: Int
    var sku_box: String
    var width_box: Int
    var length_box: Int
    var height_box: Int
    var positionOnPallete: PositionBox
    var orientation: rotation
    var id_point_section: String
    var id_section: String
    var path_to_section: [String]
}

struct LayerPallete: Content {
    var id: UUID
    var numLayer: Int
    var totalheightLayer: Int
    var filledArea: Double
    var fillPercentage: Double
    var boxed: [BoxPallete]
}

struct PalleteComputed: Content {
    var id: UUID
    var numpallete: Int
    var layers: [LayerPallete]
    var countLayer: Int
    let widthPallete: Int
    let lengthPallete: Int
    let totalHeightPallete: Int
}

struct Box: CustomStringConvertible,Content,Codable
{
    let id: UUID
    let sku_box: String
    let width_box: Int
    let length_box: Int
    let height_box: Int
    let weight_box: Int
    let is_rotated_box: Int
    let max_load_box: Int
    let id_point_section : String
    let id_section : String
    
    var width: Double { Double(width_box) }
    var length: Double { Double(length_box) }
    var height: Double { Double(height_box) }
    var weight: Double { Double(weight_box) }
    var maxLoad: Double { Double(max_load_box) }
    var description: String {
        return "Коробка \(sku_box): \(width_box)x\(length_box)x\(height_box), Вес: \(weight_box), Макс. нагрузка: \(max_load_box), Поворот: \(is_rotated_box == 1 ? "Да" : "Нет")"
    }
}

struct Layer: CustomStringConvertible
{
    let height: Double
    var boxes: [(box: Box, position: (x: Double, y: Double), orientation: rotation)]
    let palletWidth: Double
    let palletLength: Double
    
    var filledArea: Double {
        boxes.reduce(0) { $0 + $1.box.width * $1.box.length }
    }
    
    var fillPercentage: Double {
        filledArea / (palletWidth * palletLength)
    }
    
    var description: String {
        var desc = "Слой (высота: \(height), заполнение: \(String(format: "%.1f", fillPercentage * 100))%):\n"
        for (index, box) in boxes.enumerated() {
            desc += "  \(index + 1). \(box.box), Позиция: (\(box.position.x), \(box.position.y)), Ориентация: \(box.orientation)\n"
        }
        return desc
    }
}

struct Pallet: CustomStringConvertible
{
    let id_number: Int
    let width: Double
    let length: Double
    let maxHeight: Double
    var layers: [Layer]
    
    var totalHeight: Double {
        layers.reduce(0) { $0 + $1.height }
    }
    
    var description: String {
        var desc = "Паллета \(id_number):\n"
        desc += "Количество слоев: \(layers.count)\n"
        desc += "Общая высота: \(totalHeight)/\(maxHeight)\n"
        for (index, layer) in layers.enumerated() {
            desc += "Слой \(index + 1):\n"
            desc += layer.description
            desc += visualizeLayer(layer: layer, palletWidth: width, palletLength: length)
        }
        return desc
    }
}

enum rotation : Int, Codable
{
    case normal = 0
    case rotated = 1
    case onside_normal = 2 
    case onside_rotated = 3 
    case onfront_normal = 4
    case onfront_rotated = 5 
}

func visualizeLayer(layer: Layer, palletWidth: Double, palletLength: Double) -> String
{
    let cellSize = 1.0
    let gridWidth = Int(palletWidth / cellSize)
    let gridLength = Int(palletLength / cellSize)
    
    var grid = Array(repeating: Array(repeating: "..", count: gridLength), count: gridWidth)
    
    let colors = ["\u{001B}[31m", "\u{001B}[32m", "\u{001B}[33m", "\u{001B}[34m",
                  "\u{001B}[35m", "\u{001B}[36m"]
    for (index, box) in layer.boxes.enumerated()
    {
        let colorBox = colors.randomElement()!
        let xStart = Int(box.position.x / cellSize)
        let yStart = Int(box.position.y / cellSize)
        
        var xEnd = 0
        var yEnd = 0
        
        if ( box.orientation == .normal )
        {
            xEnd = min(xStart + Int(box.box.width / cellSize), gridWidth)
            yEnd = min(yStart + Int(box.box.length / cellSize), gridLength)
        }
        else if ( box.orientation == .rotated )
        {
            xEnd = min(xStart + Int(box.box.length / cellSize), gridWidth)
            yEnd = min(yStart + Int(box.box.width / cellSize), gridLength)
        }
        
        for x in xStart..<xEnd {
            for y in yStart..<yEnd {
                if x < gridWidth && y < gridLength {
                    grid[x][y] = (index + 1 < 10) ? "\(colorBox)0\(index + 1)" : "\(colorBox)\(index + 1)"
                }
            }
        }
    }
    
    var visualization = "Визуализация слоя:\n"
    for row in grid {
        visualization += row.joined(separator: "") + "\n"
    }
    return visualization
}
