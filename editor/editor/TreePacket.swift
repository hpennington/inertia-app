//
//  TreePacket.swift
//  Inertia App
//
//  Created by Hayden Pennington on 9/8/25.
//

import Inertia
import Foundation
import Observation

@Observable
final class TreePacket: Identifiable, Equatable, Hashable, CustomStringConvertible {
    public let id = UUID()
    static func == (lhs: TreePacket, rhs: TreePacket) -> Bool {
        lhs.id == rhs.id && lhs.tree == rhs.tree && lhs.actionableIds == rhs.actionableIds
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(tree)
        hasher.combine(actionableIds)
    }
    
    var description: String {
        "tree: \(tree), actionableIds: \(actionableIds)"
    }
    
    var tree: Tree
    var actionableIds: Set<ActionableIdPair>
    
    init(tree: Tree, actionableIds: Set<ActionableIdPair>) {
        self.tree = tree
        self.actionableIds = actionableIds
    }
}
