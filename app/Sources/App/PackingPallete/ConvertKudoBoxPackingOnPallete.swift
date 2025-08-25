//
//  ConvertKudoBoxPackingOnPallete.swift
//  
//
//  Created by Артем Стратиенко on 04.04.2025.
//

import Foundation

extension PackingOnPallete
{
    func sendComputedPalleteWithOrderID( orderID : String , pallete : [Pallet],  router_core : DijkstraAlgorithm, pointStart : String ) ->[String:[PalleteComputed]] {
        return [orderID:convertPalletsToComputedWithRouter(pallete,router_core : router_core, pointStart : pointStart )]
    }
    func convertPalletsToComputedWithRouter(_ pallets: [Pallet], router_core: DijkstraAlgorithm, pointStart: String) -> [PalleteComputed] {
        return pallets.map { pallet in
            // Для каждой паллеты начинаем с начальной точки
            var currentPoint: String = pointStart
            var currentPath: [String] = []
            
            let layers = pallet.layers.indices.map { index in
                let layer = pallet.layers[index]
                
                let boxes = layer.boxes.indices.map { boxIndex in
                    let boxData = layer.boxes[boxIndex]
                    let pointEnd = boxData.box.id_point_section
                    
                    // Вычисляем новый маршрут
                    let path: [String] = {
                        // Если точка назначения совпадает с текущей
                        if currentPoint == pointEnd {
                            return currentPath
                        }
                                  
                        // Получаем новый маршрут
                        guard let route = router_core.shortestPath(from: currentPoint, to: pointEnd) else {
                            print("Маршрута нет \(currentPoint) to \(pointEnd)")
                            return []
                        }
                        return route.path
                    }()
                    
                    // Обновляем текущую точку и маршрут
                    currentPoint = pointEnd
                    currentPath = path
                    
                    return BoxPallete(
                        id: boxData.box.id,
                        orderPrior: boxIndex + 1,
                        sku_box: boxData.box.sku_box,
                        width_box: boxData.box.width_box,
                        length_box: boxData.box.length_box,
                        height_box: boxData.box.height_box,
                        positionOnPallete: PositionBox(x: boxData.position.x, y: boxData.position.y),
                        orientation: boxData.orientation,
                        id_point_section: boxData.box.id_point_section,
                        id_section: boxData.box.id_section,
                        path_to_section: path
                    )
                }
                
                return LayerPallete(
                    id: UUID(),
                    numLayer: index + 1,
                    totalheightLayer: Int(layer.height),
                    filledArea: layer.filledArea,
                    fillPercentage: layer.fillPercentage,
                    boxed: boxes
                )
            }
            
            return PalleteComputed(
                id: UUID(),
                numpallete: pallet.id_number,
                layers: layers,
                countLayer: layers.count,
                widthPallete: Int(pallet.width),
                lengthPallete: Int(pallet.length),
                totalHeightPallete: Int(pallet.totalHeight)
            )
        }
    }

    func convertPalletsToComputed(_ pallets: [Pallet] ) -> [PalleteComputed] {
        return pallets.map { pallet in
            let layers = pallet.layers.enumerated().map { (index, layer) -> LayerPallete in
                let boxes = layer.boxes.enumerated().map { (boxIndex, boxData) -> BoxPallete in
                    return BoxPallete(
                        id: boxData.box.id,
                        orderPrior: boxIndex + 1,
                        sku_box: boxData.box.sku_box,
                        width_box: boxData.box.width_box,
                        length_box: boxData.box.length_box,
                        height_box: boxData.box.height_box,
                        positionOnPallete: PositionBox(x: boxData.position.x, y: boxData.position.y),
                        orientation: boxData.orientation,
                        id_point_section: boxData.box.id_point_section,
                        id_section: boxData.box.id_section,
                        path_to_section: []
                    )
                }
                return LayerPallete(
                    id: UUID(),
                    numLayer: index + 1,
                    totalheightLayer: Int(layer.height),
                    filledArea: layer.filledArea,
                    fillPercentage: layer.fillPercentage,
                    boxed: boxes
                )
            }
            return PalleteComputed(
                id: UUID(),
                numpallete: pallet.id_number,
                layers: layers,
                countLayer: layers.count,
                widthPallete: Int(pallet.width),
                lengthPallete: Int(pallet.length),
                totalHeightPallete: Int(pallet.totalHeight)
            )
        }
    }
}

