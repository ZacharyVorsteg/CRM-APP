//
//  ValidatedTextField.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    let isRequired: Bool
    let keyboardType: UIKeyboardType
    let hasError: Bool
    let onChanged: () -> Void
    
    init(
        _ title: String,
        text: Binding<String>,
        isRequired: Bool = false,
        keyboardType: UIKeyboardType = .default,
        hasError: Bool = false,
        onChanged: @escaping () -> Void = {}
    ) {
        self.title = title
        self._text = text
        self.isRequired = isRequired
        self.keyboardType = keyboardType
        self.hasError = hasError
        self.onChanged = onChanged
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(hasError ? Color.red : Color.clear, lineWidth: 2)
                )
                .onChange(of: text) { _, _ in
                    onChanged()
                }
        }
    }
}

struct RequiredFieldIndicator: View {
    var body: some View {
        HStack {
            Image(systemName: "asterisk")
                .font(.caption2)
                .foregroundColor(.red)
            Text("Required field")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ValidatedTextField(
        "First Name",
        text: .constant(""),
        isRequired: true,
        hasError: false
    )
    .padding()
}
