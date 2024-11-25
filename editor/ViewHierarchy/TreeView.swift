//
//  TreeView.swift
//  Inertia Pro
//
//  Created by Hayden Pennington on 11/25/24.
//

import SwiftUI

struct TreeItem {
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
                Button {
                    toggleExpanded()
                } label: {
                    Image(systemName: isNodeExpanded ? "chevron.down" : "chevron.right")
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .opacity(isLeafNode ? 0.0 : 1.0)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(isLeafNode || isDescendantSelected ? true : false)
                
                Text(item.displayName)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                        .padding(.leading, 8)
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
            Text(rootItem.displayName)
                .foregroundStyle(.gray)
            Divider()
            TreeNode(item: rootItem, isExpanded: $isExpanded, isSelected: isSelected)
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
    
    TreeView(id: "abc", displayName: "ABC", rootItem: rootItem, isSelected: .constant(Set()))
        .frame(minWidth: 200, minHeight: 200)
}
