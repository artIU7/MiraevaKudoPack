//
//  ComputingRoute.swift
//  
//
//  Created by Артем Стратиенко on 05.04.2025.
//
import Foundation
import Collections
import Fluent
import Vapor


struct Node: Hashable {
    let id: String
    let x: Int
    let y: Int
}

struct Edge {
    let node1: String
    let node2: String
}

struct PriorityElement: Comparable {
    let node: String
    let distance: Double
    
    static func < (lhs: PriorityElement, rhs: PriorityElement) -> Bool {
        return lhs.distance < rhs.distance
    }
    
    static func == (lhs: PriorityElement, rhs: PriorityElement) -> Bool {
        return lhs.distance == rhs.distance
    }
}

class DijkstraAlgorithm {
    private let nodes: [String: Node]
    private let edges: [Edge]
    
    init(nodes: [Node], edges: [Edge]) {
        self.nodes = Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) })
        self.edges = edges
    }
    
    private func calculateDistance(from node1Id: String, to node2Id: String) -> Double {
        guard let node1 = nodes[node1Id], let node2 = nodes[node2Id] else {
            return Double.infinity
        }
        let dx = node1.x - node2.x
        let dy = node1.y - node2.y
        return sqrt(Double(dx*dx + dy*dy))
    }
    
    func shortestPath(from startId: String, to endId: String) -> (path: [String], distance: Double)?
    {
        guard nodes[startId] != nil, nodes[endId] != nil else {
            return nil
        }
        
        // Строим список смежности с вычисленными расстояниями
        var adjacencyList = [String: [(node: String, distance: Double)]]()
        for edge in edges {
            let distance = calculateDistance(from: edge.node1, to: edge.node2)
            adjacencyList[edge.node1, default: []].append((edge.node2, distance))
            adjacencyList[edge.node2, default: []].append((edge.node1, distance))
        }
        
        var distances = [String: Double]()
        var predecessors = [String: String]()
        var visited = Set<String>()
        
        // Инициализация расстояний
        for node in nodes.keys {
            distances[node] = node == startId ? 0 : Double.infinity
        }
        
        var priorityQueue = Heap<PriorityElement>()
        priorityQueue.insert(PriorityElement(node: startId, distance: 0))
        
        while let current = priorityQueue.popMin() {
            let currentNode = current.node
            let currentDistance = current.distance
            
            if visited.contains(currentNode) { continue }
            visited.insert(currentNode)
            
            // Если достигли конечной точки
            if currentNode == endId {
                break
            }
            
            // Обрабатываем соседей
            for neighbor in adjacencyList[currentNode] ?? [] {
                let newDistance = currentDistance + neighbor.distance
                
                if distances[neighbor.node] != nil {
                    if newDistance < distances[neighbor.node]! {
                        distances[neighbor.node] = newDistance
                        predecessors[neighbor.node] = currentNode
                        priorityQueue.insert(PriorityElement(node: neighbor.node, distance: newDistance))
                    }
                } else {
                    print("Узел не найден - для выбранного ребра !")
                }
            }
        }
        
        guard distances[endId]! != Double.infinity else {
            return nil
        }
        
        // Восстанавливаем путь для дальнейшей передачи в API
        var path = [String]()
        var current: String? = endId
        while let node = current {
            path.append(node)
            current = predecessors[node]
        }
        
        return (path.reversed(), distances[endId]!)
    }
}
