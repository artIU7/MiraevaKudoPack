//
//  KudoBoxPackingOnPallete.swift
//  
//
//  Created by Артем Стратиенко on 01.04.2025.
//

import Foundation
import Collections


// Параметры алгоритма
// Минимальная площадь опоры для коробок размещаемых выше первого слоя ( % )
var minSupportRatio: Double = 0.70
// Минимальное перекрытие слоя коробками ( % )
var minLayerFillRatio: Double = 0.70
// Перепад высоты слоя ( см )
var heightTolerance: Double = 2
// Добавление слоев разных высот
var heightLayerDiff : Int = 0 // 0 - не разрешаем собирать разной высоты слои с 3 чекпоинта
// Размещение коробок по углам паллеты для покрытия всей площади
var type_packing : Int = 0 // 0 -  разрешаем собирать по углам

class PackingOnPallete
{
    // Проверяем опору корбки на нижний слой
    func isSupported(position: (x: Double, y: Double), box: Box, previousLayer: Layer , orientation : rotation ) -> Bool
    {
        let boxArea = box.width * box.length
        var supportedArea = 0.0
        
        if ( orientation == .normal  )
        {
            for previousBox in previousLayer.boxes
            {
                // Проверяем в какой ориентации расположена коробка на нижнем слое
                if ( previousBox.orientation == .normal )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .rotated )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_normal )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_normal )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
            }
        }
        else if ( orientation == .rotated  )
        {
            for previousBox in previousLayer.boxes
            {
                 // Проверяем в какой ориентации расположена коробка на нижнем слое
                if ( previousBox.orientation == .normal )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .rotated )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_normal )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_normal )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
            }
        }
        else if ( orientation == .onside_normal  )
        {
            for previousBox in previousLayer.boxes
            {
                 // Проверяем в какой ориентации расположена коробка на нижнем слое
                if ( previousBox.orientation == .normal )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .rotated )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_normal )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_normal )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.width, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
            }
        }
        else if ( orientation == .onside_rotated  )
        {
            for previousBox in previousLayer.boxes
            {
                 // Проверяем в какой ориентации расположена коробка на нижнем слое
                if ( previousBox.orientation == .normal )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .rotated )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_normal )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_normal )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.width, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
            }
        }
        else if ( orientation == .onfront_normal  )
        {
            for previousBox in previousLayer.boxes
            {
                 // Проверяем в какой ориентации расположена коробка на нижнем слое
                if ( previousBox.orientation == .normal )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .rotated )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_normal )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_normal )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.height, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.length, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
            }
        }
        else if ( orientation == .onfront_rotated  )
        {
            for previousBox in previousLayer.boxes
            {
                 // Проверяем в какой ориентации расположена коробка на нижнем слое
                if ( previousBox.orientation == .normal )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .rotated )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_normal )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.width) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onside_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.width) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_normal )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.height) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.length) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
                else if ( previousBox.orientation == .onfront_rotated )
                {
                    let xOverlap = max(0, min(position.x + box.length, previousBox.position.x + previousBox.box.length) - max(position.x, previousBox.position.x))
                    let yOverlap = max(0, min(position.y + box.height, previousBox.position.y + previousBox.box.height) - max(position.y, previousBox.position.y))
                    supportedArea += xOverlap * yOverlap
                }
            }
        }
        
        return supportedArea >= boxArea * minSupportRatio
    }
    
    func isBoxAbove(position: (x: Double, y: Double), box: Box, previousBox: (box: Box, position: (x: Double, y: Double), orientation: rotation), orientation : rotation ) -> Bool
    {
        var boxXEnd = 0.0
        var boxYEnd = 0.0

        if ( orientation == .normal )
        {
            boxXEnd = position.x + box.width
            boxYEnd = position.y + box.length
        }
        else if ( orientation == .rotated )
        {
            boxXEnd = position.x + box.length
            boxYEnd = position.y + box.length
        }
        else if ( orientation == .onside_normal )
        {
            boxXEnd = position.x + box.width
            boxYEnd = position.y + box.height
        }
        else if ( orientation == .onside_rotated )
        {
            boxXEnd = position.x + box.height
            boxYEnd = position.y + box.width
        }
        else if ( orientation == .onfront_normal )
        {
            boxXEnd = position.x + box.height
            boxYEnd = position.y + box.length
        }
        else if ( orientation == .onfront_rotated )
        {
            boxXEnd = position.x + box.length
            boxYEnd = position.y + box.height
        }
        // Проверяем в какой ориентации расположена коробка на нижнем слое
        var previousBoxXEnd = 0.0
        var previousBoxYEnd = 0.0
        
        if ( previousBox.orientation == .normal )
        {
            previousBoxXEnd = previousBox.position.x + previousBox.box.width
            previousBoxYEnd = previousBox.position.y + previousBox.box.length
        }
        else if ( previousBox.orientation == .rotated )
        {
            previousBoxXEnd = previousBox.position.x + previousBox.box.length
            previousBoxYEnd = previousBox.position.y + previousBox.box.width
        }
        else if ( previousBox.orientation == .onside_normal )
        {
            previousBoxXEnd = previousBox.position.x + previousBox.box.width
            previousBoxYEnd = previousBox.position.y + previousBox.box.height
        }
        else if ( previousBox.orientation == .onside_rotated )
        {
            previousBoxXEnd = previousBox.position.x + previousBox.box.height
            previousBoxYEnd = previousBox.position.y + previousBox.box.width
        }
        else if ( previousBox.orientation == .onfront_normal )
        {
            previousBoxXEnd = previousBox.position.x + previousBox.box.height
            previousBoxYEnd = previousBox.position.y + previousBox.box.length
        }
        else if ( previousBox.orientation == .onfront_rotated )
        {
            previousBoxXEnd = previousBox.position.x + previousBox.box.length
            previousBoxYEnd = previousBox.position.y + previousBox.box.height
        }
        return position.x < previousBoxXEnd && boxXEnd > previousBox.position.x &&
        position.y < previousBoxYEnd && boxYEnd > previousBox.position.y
    }
    
    func canSupportWeight(of newBox: Box, at position: (x: Double, y: Double), previousLayer: Layer, orientation : rotation ) -> Bool {
        for prevBox in previousLayer.boxes {
            if isBoxAbove(position: position, box: newBox, previousBox: prevBox , orientation : orientation ) {
                if newBox.weight > prevBox.box.maxLoad {
                    return false
                }
            }
        }
        return true
    }
    func findPositionWithoutCompleteLayer(for width: Double, length: Double, in occupiedSpace: [[Bool]], palletWidth: Double, palletLength: Double) -> (x: Double, y: Double)?
    {
        // Отключчим временно для тестов (в параметрах заказа флаг)
        // На второй сессии были предоставленны фото по заполнению реального паллета
        // Коробки максимально размазанны по площади паллета
        // Сначала проверяем угловые точки
        if ( type_packing == 0 )
        {
            let checkPoints = [
                (x: 0, y: 0),
                (x: Int(palletWidth) - Int(width), y: 0),
                (x: 0, y: Int(palletLength) - Int(length)),
                (x: Int(palletWidth) - Int(width), y: Int(palletLength) - Int(length))
            ]
            
            for point in checkPoints {
                if canPlaceBox(at: (x: point.x, y: point.y), width: Int(width), length: Int(length),
                               in: occupiedSpace, palletWidth: Int(palletWidth), palletLength: Int(palletLength)) {
                    return (Double(point.x), Double(point.y))
                }
            }
        }
        // Затем проверяем обратным порядком
        for y in (0..<Int(palletLength)).reversed() {
            for x in (0..<Int(palletWidth)).reversed() {
                if canPlaceBox(at: (x: x, y: y), width: Int(width), length: Int(length),
                               in: occupiedSpace, palletWidth: Int(palletWidth), palletLength: Int(palletLength)) {
                    return (Double(x), Double(y))
                }
            }
        }
        return nil
    }
    func findPosition(for width: Double, length: Double, in occupiedSpace: [[Bool]], palletWidth: Double, palletLength: Double, box : Box, previousLayer: Layer , orientation: rotation) -> (x: Double, y: Double)?
    {
        // Устанавливаем ориентацию для коробки
        // Отключчим временно для тестов
        // На второй сессии были предоставленны фото по заполнению реального паллета
        // Коробки максимально размазанны по площади паллета        
        // Сначала проверяем угловые точки
        if ( type_packing == 0 )
        {
            let checkPoints = [
                (x: 0, y: 0),
                (x: Int(palletWidth) - Int(width), y: 0),
                (x: 0, y: Int(palletLength) - Int(length)),
                (x: Int(palletWidth) - Int(width), y: Int(palletLength) - Int(length))
            ]
            
            for point in checkPoints {
                if canPlaceBox(at: (x: point.x, y: point.y), width: Int(width), length: Int(length),
                               in: occupiedSpace, palletWidth: Int(palletWidth), palletLength: Int(palletLength))
                {
                    if !isSupported(position: (Double(point.x), Double(point.y)), box: box, previousLayer: previousLayer, orientation: orientation) ||
                        !canSupportWeight(of: box, at: (Double(point.x), Double(point.y)), previousLayer: previousLayer , orientation : orientation)
                    {
                        continue
                    }
                    return (Double(point.x), Double(point.y))
                }
            }
        }
        
        // Затем проверяем обратным порядком
        for y in (0..<Int(palletLength)).reversed() {
            for x in (0..<Int(palletWidth)).reversed() {
                if canPlaceBox(at: (x: x, y: y), width: Int(width), length: Int(length),
                               in: occupiedSpace, palletWidth: Int(palletWidth), palletLength: Int(palletLength))
                {
                    if !isSupported(position: (Double(x), Double(y)), box: box, previousLayer: previousLayer, orientation: orientation) ||
                        !canSupportWeight(of: box, at: (Double(x), Double(y)), previousLayer: previousLayer, orientation: orientation)
                    {
                        continue
                    }
                    return (Double(x), Double(y))
                }
            }
        }
        return nil
    }
    
    func canPlaceBox(at position: (x: Int, y: Int), width: Int, length: Int, in occupiedSpace: [[Bool]], palletWidth: Int, palletLength: Int) -> Bool
    {
        if position.x + width > palletWidth || position.y + length > palletLength {
            return false
        }
        for i in position.x..<position.x + width {
            for j in position.y..<position.y + length {
                if occupiedSpace[i][j] {
                    return false
                }
            }
        }
        return true
    }
    
    func markOccupiedSpace(for width: Double, length: Double, at position: (x: Double, y: Double), in occupiedSpace: inout [[Bool]])
    {
        for i in Int(position.x)..<Int(position.x + width) {
            for j in Int(position.y)..<Int(position.y + length) {
                if i < occupiedSpace.count && j < occupiedSpace[i].count {
                    occupiedSpace[i][j] = true
                }
            }
        }
    }
}

extension PackingOnPallete
{
    func packBoxesOnPallets(boxes: [Box], palletWidth: Double, palletLength: Double, maxPalletHeight: Double) -> [Pallet]
    {
        var pallets: [Pallet] = []

        var remainingBoxes = boxes.sorted {
            $0.weight > $1.weight ||
            ($0.weight == $1.weight && $0.height > $1.height)
            // Вклюаем / Отключаем по обьему ( большей площади ) - ограничение в ТЗ по весу !
            ||
            ($0.weight == $1.weight && $0.height == $1.height && $0.width*$0.length > $1.width*$1.length)
        }
        
        while !remainingBoxes.isEmpty {
            var pallet = Pallet(id_number: pallets.count + 1, width: palletWidth, length: palletLength,
                              maxHeight: maxPalletHeight, layers: [])
            
            while pallet.totalHeight < maxPalletHeight && !remainingBoxes.isEmpty {
                var layerBoxes: [(box: Box, position: (x: Double, y: Double), orientation: rotation)] = []
                var occupiedSpace = Array(repeating: Array(repeating: false, count: Int(palletLength)), count: Int(palletWidth))
                var layerHeight: Double = 0
                var allowMixedHeights = false
                var isFinalLayer = false
                
                // Первоначальное заполнение
                var i = 0
                while i < remainingBoxes.count {
                    let box = remainingBoxes[i]

                    let orientations = [
                        (width: box.width, length: box.length, height: box.height, orientation: rotation.normal),
                        (width: box.length, length: box.width, height: box.height, orientation: rotation.rotated),
                        (width: box.width, length: box.height, height: box.length, orientation: rotation.onside_normal),
                        (width: box.height, length: box.width, height: box.length, orientation: rotation.onside_rotated),
                        (width: box.height, length: box.length, height: box.width, orientation: rotation.onfront_normal),
                        (width: box.length, length: box.height, height: box.width, orientation: rotation.onfront_rotated)
                    ]

                    var placed = false
                    for orientation in orientations 
                    {
                        if box.is_rotated_box == 0 && ( orientation.orientation == .onside_normal  || 
                                                        orientation.orientation == .onside_rotated || 
                                                        orientation.orientation == .onfront_normal || 
                                                        orientation.orientation == .onfront_rotated 
                                                      ) {
                             // вращение по плоскости разрешаем всем 
                             // по граням - смотрим флаг [ is_rotated_box ]
                             continue
                        }
                        
                        if layerHeight == 0 {
                            layerHeight = orientation.height
                        }
                        else if !allowMixedHeights && abs(orientation.height - layerHeight) > heightTolerance
                        {
                            // Если в параметрах рассчета алгоритма установим галочку - разная высота в слое , то больше оптимизируем паллета
                            if heightLayerDiff == 0
                            {
                                continue
                            }
                        }
                        if !pallet.layers.isEmpty
                        {
                            let previousLayer = pallet.layers.last!
                            
                            if let position = findPosition(for: orientation.width, length: orientation.length,
                                                           in: occupiedSpace, palletWidth: palletWidth, palletLength: palletLength, box : box, previousLayer : previousLayer, orientation: orientation.orientation)
                            {
                                layerBoxes.append((box: box, position: position, orientation: orientation.orientation))
                                markOccupiedSpace(for: orientation.width, length: orientation.length,
                                                 at: position, in: &occupiedSpace)
                                remainingBoxes.remove(at: i)
                                placed = true
                                break
                            }
                        }
                        else
                        {
                            if let position = findPositionWithoutCompleteLayer(for: orientation.width, length: orientation.length,
                                                           in: occupiedSpace, palletWidth: palletWidth, palletLength: palletLength)
                            {
                                layerBoxes.append((box: box, position: position, orientation: orientation.orientation))
                                markOccupiedSpace(for: orientation.width, length: orientation.length,
                                                 at: position, in: &occupiedSpace)
                                remainingBoxes.remove(at: i)
                                placed = true
                                break
                            }
                        }
                    }
                    if !placed { i += 1 }
                }
                // Проверка условий для дозаполнения
                let currentLayer = Layer(height: layerBoxes.map { $0.box.height }.max() ?? 0,
                                        boxes: layerBoxes,
                                        palletWidth: palletWidth,
                                        palletLength: palletLength)
                let fillPercentage = currentLayer.fillPercentage
                let remainingHeight = maxPalletHeight - pallet.totalHeight
                let remainingHeightAfterLayer = remainingHeight - currentLayer.height
                let minRemainingBoxHeight = remainingBoxes.map { $0.height }.min() ?? 0
                let maxRemainingBoxHeight = remainingBoxes.map { $0.height }.max() ?? 0
                
                let isLastPossibleLayer = remainingHeightAfterLayer < minRemainingBoxHeight
                let cannotFitNextLayer = remainingHeight < maxRemainingBoxHeight
                
                // Условие если у нас есть количество коробок одной высоты отсортированных по весу, не перекрывающие слой (первый ) на определенный процент ( параметр minLayerFillRatio)
                // добавим флаг включения
                var is_use_max_weight_up = false
                // Не используем этот параметр вообще - на чек-поинте № 3 было сказанно, что это одно из главных условий
                // КОРОБКИ ТЯЖЕЛЫЕ ВСЕГДА НА ПЕРВЫЙ СЛОЙ РАЗМЕЩАЕМ
                if ( is_use_max_weight_up )
                {
                    if fillPercentage < minLayerFillRatio && remainingHeight == maxPalletHeight && !remainingBoxes.isEmpty  {
                        // Если слой недостаточно заполнен, возвращаем коробки обратно
                        for boxInLayer in layerBoxes {
                            remainingBoxes.append(boxInLayer.box)
                        }
                        // Сортируем коробки снова
                        remainingBoxes = remainingBoxes.sorted {
                            $0.weight > $1.weight ||
                            ($0.weight == $1.weight && $0.height > $1.height)
                        }
                        print("Слой заполнен только на \(String(format: "%.1f", fillPercentage * 100))% - отменяем слой и пробуем другую высоту")
                        break
                        // Прерываем формирование этого слоя
                    }
                }

                if fillPercentage < minLayerFillRatio || isLastPossibleLayer || cannotFitNextLayer {
                    allowMixedHeights = true
                    isFinalLayer = true
                    var j = 0
                    while j < remainingBoxes.count {
                        let box = remainingBoxes[j]
                        
                    let orientations = [
                        (width: box.width, length: box.length, height: box.height, orientation: rotation.normal),
                        (width: box.length, length: box.width, height: box.height, orientation: rotation.rotated),
                        (width: box.width, length: box.height, height: box.length, orientation: rotation.onside_normal),
                        (width: box.height, length: box.width, height: box.length, orientation: rotation.onside_rotated),
                        (width: box.height, length: box.length, height: box.width, orientation: rotation.onfront_normal),
                        (width: box.length, length: box.height, height: box.width, orientation: rotation.onfront_rotated)
                    ]
                        
                        var placedAdditional = false
                        for orientation in orientations 
                        {
                            if box.is_rotated_box == 0 && ( orientation.orientation == .onside_normal  || 
                                                            orientation.orientation == .onside_rotated || 
                                                            orientation.orientation == .onfront_normal || 
                                                            orientation.orientation == .onfront_rotated 
                                                          ) {
                                // вращение по плоскости разрешаем всем 
                                // по граням - смотрим флаг [ is_rotated_box ]
                                continue
                            }
                            
                            let potentialMaxHeight = max(layerHeight, orientation.height)
                            if pallet.totalHeight + potentialMaxHeight > maxPalletHeight {
                                continue
                            }
                            
                            if !pallet.layers.isEmpty
                            {
                                let previousLayer = pallet.layers.last!
                                
                                if let position = findPosition(for: orientation.width, length: orientation.length,
                                                               in: occupiedSpace, palletWidth: palletWidth, palletLength: palletLength, box : box, previousLayer : previousLayer, orientation: orientation.orientation)
                                {
                                    layerBoxes.append((box: box, position: position, orientation: orientation.orientation))
                                    markOccupiedSpace(for: orientation.width, length: orientation.length,
                                                     at: position, in: &occupiedSpace)
                                    remainingBoxes.remove(at: j)
                                    placedAdditional = true
                                    layerHeight = max(layerHeight, box.height)
                                    break
                                }
                            }
                            else
                            {
                                if let position = findPositionWithoutCompleteLayer(for: orientation.width, length: orientation.length,
                                                               in: occupiedSpace, palletWidth: palletWidth, palletLength: palletLength)
                                {
                                    layerBoxes.append((box: box, position: position, orientation: orientation.orientation))
                                    markOccupiedSpace(for: orientation.width, length: orientation.length,
                                                     at: position, in: &occupiedSpace)
                                    remainingBoxes.remove(at: j)
                                    placedAdditional = true
                                    layerHeight = max(layerHeight, box.height)
                                    break
                                }
                            }
                        }
                        if !placedAdditional { j += 1 }
                    }
                }
                
                let updatedLayer = Layer(height: layerBoxes.map { $0.box.height }.max() ?? 0,
                                        boxes: layerBoxes,
                                        palletWidth: palletWidth,
                                        palletLength: palletLength)
                
                if !updatedLayer.boxes.isEmpty {
                    pallet.layers.append(updatedLayer)
                    if isFinalLayer
                    {
                        break
                    }
                } else
                {
                    break
                }
            }
            
            if !pallet.layers.isEmpty {
                pallets.append(pallet)
            }
        }
        return pallets
    }
}
