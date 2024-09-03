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
    
    private let cornerRadius = 8.0
    
    var body: some View {
        Button {
            model.selectedTag.wrappedValue = tag
        } label: {
            content()
                .cornerRadius(cornerRadius)
                .overlay {
                    Group {
                        if model.selectedTag.wrappedValue == tag {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(ColorPalette.purple0, lineWidth: 2)
                        }
                    }

                }
        }
        .buttonStyle(.plain)
    }
}

struct RadioButtonContent: View {
    let title: String
    
    private let background: some ShapeStyle = Color(red: 150 / 255, green: 150 / 255, blue: 150 / 255, opacity: 0.9)
    private let foreground: some ShapeStyle = Color(red: 241 / 255, green: 241 / 255, blue: 241 / 255)
    
    var body: some View {
        Text(title)
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 44)
            .background(background)
            .foregroundStyle(foreground)
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
        .frame(maxWidth: 280)
    }
}

#Preview {
    typealias Tag = Int
    let reactTag: Tag = 0
    let swiftUITag: Tag = 1
    @State var selectedTag: Tag = reactTag
    
    return RadioGroup(selectedTag: $selectedTag) {
        RadioButton(tag: reactTag) {
            RadioButtonContent(title: "React (Web)")
        }
        
        RadioButton(tag: swiftUITag) {
            RadioButtonContent(title: "SwiftUI (iOS)")
        }
    }
}
