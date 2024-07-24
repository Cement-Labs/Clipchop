//
//  ListEmbeddedForm.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/28.
//

import SwiftUI

struct ListEmbeddedForm<Style, Content>: View where Style: FormStyle, Content: View {
    var formStyle: Style
    @ViewBuilder var content: () -> Content
    
    init(
        formStyle: Style,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.formStyle = formStyle
        self.content = content
    }
    
    init(
        @ViewBuilder content: @escaping () -> Content
    ) where Style == GroupedFormStyle {
        self.init(formStyle: GroupedFormStyle(), content: content)
    }
    
    var body: some View {
        List {
            Form {
                content()
            }
            .formStyle(formStyle)
            
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .ignoresSafeArea()
        }
    }
}
