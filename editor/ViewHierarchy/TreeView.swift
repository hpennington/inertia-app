//
//  TreeView.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 11/25/24.
//

import SwiftUI
import Inertia

struct TreeItem: Identifiable {
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
    let isExpanded: Binding<Set<String>>
    let isSelected: Binding<Set<String>>

    var isDescendantSelected: Bool {
        _isDescendantSelected(node: item)
    }
    
    func _isDescendantSelected(node: TreeItem) -> Bool {
        if let children = node.children {
            for child in children {
                if isSelected.wrappedValue.contains(child.id) {
                    return true
                }
            }
            
            for child in children {
                return _isDescendantSelected(node: child)
            }
        }
        
        return false
    }
    
    var isNodeExpanded: Bool {
        isExpanded.wrappedValue.contains(item.id) || isDescendantSelected
    }
    
    var isNodeSelected: Bool {
        isSelected.wrappedValue.contains(item.id)
    }
    
    var isLeafNode: Bool {
        item.children == nil
    }
    
    func toggleExpanded() {
        if isNodeExpanded {
            isExpanded.wrappedValue.remove(item.id)
        } else {
            isExpanded.wrappedValue.insert(item.id)
        }
    }
    
    func toggleSelected() {
        if isNodeSelected {
            isSelected.wrappedValue.remove(item.id)
        } else {
            isSelected.wrappedValue.insert(item.id)
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
                
                Text(item.displayName)
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

            let expanded = isNodeExpanded == true
            if let children = item.children, expanded {
                ForEach(children, id: \.id) { child in
                    TreeNode(item: child, isExpanded: isExpanded, isSelected: isSelected)
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .onAppear {
            if isDescendantSelected {
                isExpanded.wrappedValue.insert(item.id)
            }
        }
        .onChange(of: isDescendantSelected) { _, newValue in
            if newValue {
                isExpanded.wrappedValue.insert(item.id)
            }
        }
    }
}

struct TreeView: View {
    let id: String
    let displayName: String
    let rootItem: TreeItem
    let isSelected: Binding<Set<String>>
    
    @State private var isExpanded: Set<String> = Set()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("View Hierarchy")
                .foregroundStyle(.gray)
            Divider()
            TreeNode(item: rootItem, isExpanded: $isExpanded, isSelected: isSelected)
        }
    }
}

struct TreeViewContainer: View {
    @Environment(\.isEnabled) var isEnabled
    
    let server: WebSocketServer
    
    func convertTreeToTreeItem(tree: Tree) -> TreeItem {
        guard let rootNode = tree.rootNode else { fatalError("rootNode is nil") }
        return convertNodeToTreeItem(node: rootNode)
    }

    private func convertNodeToTreeItem(node: Node) -> TreeItem {
        let children = node.children?.map { convertNodeToTreeItem(node: $0) } ?? []
        return TreeItem(
            id: node.id,
            displayName: node.id, // Use `id` directly as `displayName`
            children: children.isEmpty ? nil : children
        )
    }
    var body: some View {
        ScrollView {
            VStack {
                ForEach(server.treePackets, id: \.id) { treePacket in
                    TreeView(
                        id: treePacket.tree.id,
                        displayName: convertTreeToTreeItem(tree: treePacket.tree).displayName,
                        rootItem: convertTreeToTreeItem(tree: treePacket.tree),
                        isSelected: Binding(
                            get: {
                                treePacket.actionableIds
                            },
                            set: {
                                treePacket.actionableIds = $0
                                server.sendSelectedIds($0)
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
