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
                
//                Text(String(item.displayName.reversed()).prefix(8))
                Text(String(item.displayName))
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
    @Environment(\.isEnabled) var isEnabled
    let id: String
    let displayName: String
    let rootItem: TreeItem
    @Binding var isSelected: Set<String>
    
    @State private var isExpanded: Set<String> = Set()
    
    var body: some View {
        TreeNode(item: rootItem, isExpanded: $isExpanded, isSelected: $isSelected)
            .foregroundColor(!isEnabled ? .gray : nil)
            .overlay {
                if !isEnabled {
                    Color.gray.opacity(0.0125)
                        .cornerRadius(8)
                }
            }
    }
}

struct TreeViewContainerTreeViewContainer: View {
    @Environment(\.isEnabled) var isEnabled

    let appMode: SetupFlowFramework
    let isFocused: Binding<Bool>
    let server: WebSocketServer
    let updateDelegates: (_ ids: Set<ActionableIdPair>) -> Void

    @State private var treeItemCache: [String: TreeItem] = [:]

    func convertTreeToTreeItem(tree: Tree) -> TreeItem {
        // Check cache first
        if let cached = treeItemCache[tree.id] {
            return cached
        }

        guard let rootNode = tree.rootNode else { fatalError("rootNode is nil") }
        let item = convertNodeToTreeItem(node: rootNode)

        // Update cache
        DispatchQueue.main.async {
            treeItemCache[tree.id] = item
        }

        return item
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
                ForEach(server.treePackets, id: \.id) { treePacket in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("View Hierarchy")
                                .foregroundStyle(.gray)
                            Spacer(minLength: .zero)
                            FocusIndicator(isOn: isFocused)
                                .onChange(of: isFocused.wrappedValue) { _, newValue in
                                    for id in server.clients.keys {
                                        server.sendIsActionable(newValue, to: id)
                                    }
                                }
                        }

                        Divider()
                        VStack {
                            TreeView(
                                id: treePacket.tree.id,
                                displayName: convertTreeToTreeItem(tree: treePacket.tree).displayName,
                                rootItem: convertTreeToTreeItem(tree: treePacket.tree),
                                isSelected: Binding(
                                    get: {
                                        return Set(treePacket.actionableIds.map(\.hierarchyId))
                                    },
                                    set: { newIds in
                                        let idPairs = Set(newIds.map {
                                            let pattern = #"--\d+(?!.*--\d+)"#
                                            let hierarchyIdPrefix = $0.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                                            return ActionableIdPair(hierarchyIdPrefix: hierarchyIdPrefix, hierarchyId: $0)
                                        })
//
//                                        // Send to clients
                                        for client in server.clients.keys {
                                            server.sendSelectedIds(idPairs, tree: treePacket.tree, to: client)
                                        }
//
//                                        // Update local state
                                        treePacket.actionableIds = idPairs
//
//                                        // Notify delegates
                                        updateDelegates(idPairs)
                                    }
                                )
                            )
                            .disabled(!isFocused.wrappedValue && server.treePackets.count > .zero)
                        }

                    }
                    .padding(.vertical, 42)
                    .padding(.horizontal, 24)
                }
//                ForEach(server.treePackets, id: \.hashValue) { treePacket in
//
//                }
                
                if !(server.treePackets.isEmpty) {
                    Divider()
                }
            }
        }
//        .padding(.vertical, 42)
//        .padding(.horizontal, 24)
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
