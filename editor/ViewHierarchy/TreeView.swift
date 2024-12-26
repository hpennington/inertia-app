//
//  TreeView.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 11/25/24.
//

import SwiftUI
import Inertia

class TreeItem: Identifiable, Equatable, Hashable {
    static func == (lhs: TreeItem, rhs: TreeItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(children)
    }
    
    
    let id: String
    let displayName: String
    let children: [TreeItem]?
    
    init(id: String, displayName: String, children: [TreeItem]? = nil) {
        self.id = id
        self.displayName = displayName
        self.children = children
    }
}

struct TreeNode: View {
    let item: TreeItem
    @Binding var isExpanded: Set<String>
    @Binding var isSelected: Set<String>

    @State private var isDescendantSelected: Bool = false
    
    init(item: TreeItem, isExpanded: Binding<Set<String>>, isSelected: Binding<Set<String>>) {
        self.item = item
        self._isExpanded = isExpanded
        self._isSelected = isSelected
        self._isDescendantSelected = State(wrappedValue: _isDescendantSelected(node: item))
    }
    
    
    func _isDescendantSelected(node: TreeItem) -> Bool {
        if let children = node.children {
            return children.contains { isSelected.contains($0.id) || _isDescendantSelected(node: $0) }
        }
        return false
    }
//
//    func _isDescendantSelected(node: TreeItem) -> Bool {
//        if let children = node.children {
//            for child in children {
//                if isSelected.contains(child.id) {
//                    return true
//                }
//            }
//            
//            for child in children {
//                return _isDescendantSelected(node: child)
//            }
//        }
//        
//        return false
//    }
    
    var isNodeExpanded: Bool {
        isExpanded.contains(item.id) || isNodeSelected || isDescendantSelected
    }
    
    var isNodeSelected: Bool {
        isSelected.contains(item.id)
    }
    
    var isLeafNode: Bool {
        item.children == nil
    }
    
    func toggleExpanded() {
        if isNodeExpanded {
            isExpanded.remove(item.id)
        } else {
            isExpanded.insert(item.id)
        }
    }
    
    func toggleSelected() {
        if isNodeSelected {
            isSelected.remove(item.id)
        } else {
            isSelected.insert(item.id)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: .zero) {
                if !isLeafNode {
                    Button {
                        toggleExpanded()
                    } label: {
                        Image(systemName: isNodeExpanded ? "chevron.down" : "chevron.right")
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isDescendantSelected)
                }
                
                Text(String(item.displayName.reversed()).prefix(8))
                    .padding(.leading, item.children == nil ? 8 : .zero)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 24)
                    .contentShape(Rectangle())
                    
                    
                Spacer(minLength: .zero)
            }
            .background(isNodeSelected ? .accent : .clear)
            .cornerRadius(4)
            .onTapGesture {
                toggleSelected()
            }

            if let children = item.children {
                ForEach(children, id: \.hashValue) { child in
                    Group {
                        if isNodeExpanded {
                            TreeNode(item: child, isExpanded: $isExpanded, isSelected: $isSelected)
                        }
                    }
                    
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onAppear {
                            isDescendantSelected = self._isDescendantSelected(node: item)
                        }
                }
            }
        }
        .onAppear {
            isDescendantSelected = self._isDescendantSelected(node: item)
    
        }
    }
}

struct TreeView: View {
    let id: String
    let displayName: String
    let rootItem: TreeItem
    @Binding var isSelected: Set<String>
    
    @State private var isExpanded: Set<String> = Set()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("View Hierarchy")
                .foregroundStyle(.gray)
            Divider()
            TreeNode(item: rootItem, isExpanded: $isExpanded, isSelected: $isSelected)
        }
    }
}

struct TreeViewContainer: View {
    @Environment(\.isEnabled) var isEnabled
    
    let server: Binding<WebSocketServer>
    
    func convertTreeToTreeItem(tree: Tree) -> TreeItem {
        guard let rootNode = tree.rootNode else { fatalError("rootNode is nil") }
        return convertNodeToTreeItem(node: rootNode)
    }
    
    private func convertNodeToTreeItem(treeItem: TreeItem) -> TreeItem {
        let children = treeItem.children?.map { convertNodeToTreeItem(treeItem: $0) } ?? []
        return TreeItem(
            id: treeItem.id,
            displayName: treeItem.id, // Use `id` directly as `displayName`
            children: children.isEmpty ? nil : children.map {
                return convertNodeToTreeItem(treeItem: $0)
            }
        )
    }

    private func convertNodeToTreeItem(node: Node) -> TreeItem {
        let children = node.children?.map { convertNodeToTreeItem(node: $0) } ?? []
        return TreeItem(
            id: node.id,
            displayName: node.id, // Use `id` directly as `displayName`
            children: children.isEmpty ? nil : children.map {
                return convertNodeToTreeItem(treeItem: $0)
            }
        )
    }
    var body: some View {
        ScrollView {
            VStack {
                ForEach(server.treePackets, id: \.hashValue) { treePacket in
                    TreeView(
                        id: treePacket.tree.id,
                        displayName: convertTreeToTreeItem(tree: treePacket.tree.wrappedValue).displayName,
                        rootItem: convertTreeToTreeItem(tree: treePacket.tree.wrappedValue),
//                        isSelected: server.projectedValue.treePackets[index].actionableIds
                        isSelected: Binding(
                            get: {
//                                print(treePacket.actionableIds)
                                return treePacket.wrappedValue.actionableIds
                            },
                            set: {
                                treePacket.wrappedValue.actionableIds = $0
                                server.wrappedValue.sendSelectedIds($0)
                            }
                        )
                    )
                    .padding(.vertical, 42)
                    .padding(.horizontal, 24)
                }
                
                if !server.treePackets.isEmpty {
                    Divider()
                }
            }
        }
        .padding(.vertical, 42)
        .padding(.horizontal, 24)
        .foregroundColor(!isEnabled ? .gray : nil)
        .overlay {
            if !isEnabled && server.treePackets.count > .zero {
                Color.gray.opacity(0.0125)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    let rootItem = TreeItem(
        id: "0",
        displayName: "Zero",
        children: [
            TreeItem(
                id: "1",
                displayName: "One",
                children: [
                    TreeItem(id: "2", displayName: "Two", children: [
                        TreeItem(id: "4", displayName: "Four")
                    ])
                ]
            ),
            TreeItem(
                id: "3",
                displayName: "Three"
            )
        ]
    )
    
    return TreeView(id: "abc", displayName: "ABC", rootItem: rootItem, isSelected: .constant(Set()))
        .frame(minWidth: 200, minHeight: 200)
}
