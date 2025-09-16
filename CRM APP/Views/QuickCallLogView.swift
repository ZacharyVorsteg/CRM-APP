//
//  QuickCallLogView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct QuickCallLogView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLead: Lead?
    @State private var callNotes = ""
    
    var qualifiedLeads: [Lead] {
        dataManager.leads.filter { $0.status == .qualified || $0.status == .contacted }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Quick Call Log")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Prospect")
                        .font(.headline)
                    
                    if qualifiedLeads.isEmpty {
                        Text("No active prospects to call")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        Picker("Prospect", selection: $selectedLead) {
                            Text("Select prospect...").tag(nil as Lead?)
                            ForEach(qualifiedLeads) { lead in
                                Text("\(lead.fullName) - \(lead.businessType.rawValue)").tag(lead as Lead?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Text("Call Notes")
                        .font(.headline)
                    
                    TextField("What was discussed?", text: $callNotes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Log & Call") {
                        logCallAndDial()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(selectedLead == nil)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func logCallAndDial() {
        guard let lead = selectedLead else { return }
        
        let communication = Communication(
            leadId: lead.id,
            type: .phone,
            subject: "Follow-up Call",
            content: callNotes.isEmpty ? "Called prospect" : callNotes
        )
        dataManager.addCommunication(communication)
        
        dismiss()
        
        // Open phone app
        let cleanPhone = lead.phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        if let phoneURL = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(phoneURL)
        }
    }
}

#Preview {
    QuickCallLogView()
        .environmentObject(DataManager.shared)
}
