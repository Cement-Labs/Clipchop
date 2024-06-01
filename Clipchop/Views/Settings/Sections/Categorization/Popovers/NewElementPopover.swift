//
//  NewElementPopover.swift
//  Clipchop
//
//  Created by KrLite on 2024/6/1.
//
/*
import SwiftUI

struct NewElementPopover: View {
    @State private var input: String = ""
    
    var titleKey: LocalizedStringKey
    var isValidInput: (String) -> Bool = { _ in true }
    var onCompletion: (String) -> Void
    
    private var isValid: Bool {
        isValidInput(input)
    }
    
    init(
        _ titleKey: LocalizedStringKey,
        isValidInput: @escaping (String) -> Bool = { _ in true },
        onCompletion: @escaping (String) -> Void
    ) {
        self.titleKey = titleKey
        self.isValidInput = isValidInput
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        HStack {
            TextField(titleKey, text: $input)
                .frame(minWidth: 225)
                .onSubmit {
                    if isValid {
                        onCompletion(input)
                    }
                }
                .textFieldStyle(.plain)
            
            Button {
                onCompletion(input)
                input = ""
            } label: {
                Image(systemSymbol: isValid ? .arrowRightCircleFill : .exclamationmarkCircleFill)
                    .imageScale(.large)
                    .fontWeight(.semibold)
                    .if(isValid) { view in
                        view.foregroundStyle(.accent)
                    } falseExpression: { view in
                        view.foregroundStyle(.placeholder)
                    }
            }
            .buttonStyle(.borderless)
            .aspectRatio(1, contentMode: .fit)
            .disabled(!isValid)
        }
        .padding()
    }
}
*/
