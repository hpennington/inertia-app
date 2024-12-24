//
//  RadioGroup.swift
//  Vibe Animation
//
//  Created by Hayden Pennington on 9/2/24.
//

import SwiftUI

struct RadioButton<Tag: Hashable, Content: View>: View {
    @Environment(RadioGroupVM<Tag>.self) private var model: RadioGroupVM<Tag>
    let tag: Tag
    @ViewBuilder let content: () -> Content
    
    init(tag: Tag, @ViewBuilder content: @escaping () -> Content) {
        self.tag = tag
        self.content = content
    }
    
    private let cornerRadius = 4.0
    
    var isSelected: Bool {
        model.selectedTag.wrappedValue == tag
    }
    
    var body: some View {
        Button {
            model.selectedTag.wrappedValue = tag
        } label: {
            content()
                .cornerRadius(cornerRadius)
                .overlay {
                    if isSelected {
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(ColorPalette.accentTheme, lineWidth: 3)
                                .padding(0.5)
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(ColorPalette.gray3.opacity(0.25))
                        }
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

struct RadioButtonContent: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 40)
            .background(ColorPalette.gray3)
            .foregroundStyle(ColorPalette.gray5)
    }
}

@Observable
class RadioGroupVM<Tag: Hashable> {
    var selectedTag: Binding<Tag>
    
    init(selectedTag: Binding<Tag>) {
        self.selectedTag = selectedTag
    }
}

struct RadioGroup<ButtonContent: View, Tag: Hashable>: View {
    @Bindable private var vm: RadioGroupVM<Tag>
    
    let selectedTag: Binding<Tag>
    @ViewBuilder let buttons: () -> ButtonContent
    
    init(selectedTag: Binding<Tag>, @ViewBuilder buttons: @escaping () -> ButtonContent) {
        self.selectedTag = selectedTag
        self.buttons = buttons
        self.vm = RadioGroupVM(selectedTag: selectedTag)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            buttons()
                .environment(vm)
        }
    }
}
typealias PreviewTag = Int
fileprivate let previewReactTag: PreviewTag = 0
fileprivate let previewSwiftUITag: PreviewTag = 1

#Preview {
    @Previewable @State var selectedTag: PreviewTag = previewReactTag
    RadioGroup(selectedTag: $selectedTag) {
        RadioButton(tag: reactTag) {
            RadioButtonContent(title: "React (Web)")
        }
        
        RadioButton(tag: swiftUITag) {
            RadioButtonContent(title: "SwiftUI (iOS)")
        }
    }
}
