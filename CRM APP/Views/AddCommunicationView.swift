//
//  AddCommunicationView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

struct AddCommunicationView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let leadId: UUID
    
    @State private var type = CommunicationType.email
    @State private var subject = ""
    @State private var content = ""
    @State private var isOutgoing = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Communication Details") {
                    Picker("Type", selection: $type) {
                        ForEach(CommunicationType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: iconForType(type))
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    TextField("Subject", text: $subject)
                    
                    Toggle("Outgoing", isOn: $isOutgoing)
                }
                
                Section("Content") {
                    TextField("Details or notes...", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
            }
            .navigationTitle("New Communication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCommunication()
                    }
                    .disabled(subject.isEmpty)
                }
            }
        }
        .onAppear {
            // Set default subject based on type
            subject = type.rawValue
        }
    }
    
    private func saveCommunication() {
        let communication = Communication(
            leadId: leadId,
            type: type,
            subject: subject,
            content: content,
            isOutgoing: isOutgoing
        )
        
        dataManager.addCommunication(communication)
        dismiss()
    }
    
    private func iconForType(_ type: CommunicationType) -> String {
        switch type {
        case .email: return "envelope"
        case .phone: return "phone"
        case .text: return "message"
        case .meeting: return "person.2"
        case .note: return "note.text"
        }
    }
}

#Preview {
    AddCommunicationView(leadId: UUID())
        .environmentObject(DataManager.shared)
}
