//
//  LeadDetailView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct LeadDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let lead: Lead
    @State private var showingAddCommunication = false
    @State private var showingEditLead = false
    
    var communications: [Communication] {
        dataManager.getCommunicationsForLead(lead.id)
    }
    
    var deals: [Deal] {
        dataManager.getDealsForLead(lead.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Lead Info Header
                    VStack(spacing: 12) {
                        Text(lead.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.blue)
                                Text(lead.email)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundColor(.green)
                                Text(lead.phone)
                                Spacer()
                            }
                            
                            if let address = lead.propertyAddress {
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.orange)
                                    Text(address)
                                    Spacer()
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        HStack {
                            StatusBadge(status: lead.status.rawValue, color: statusColor(for: lead.status))
                            
                            if let value = lead.estimatedValue {
                                Text(formatCurrency(value))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick Actions
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickActionButton(
                            title: "Call",
                            icon: "phone.fill",
                            color: .green
                        ) {
                            makeCall()
                        }
                        
                        QuickActionButton(
                            title: "Email",
                            icon: "envelope.fill",
                            color: .blue
                        ) {
                            sendEmail()
                        }
                        
                        QuickActionButton(
                            title: "Create Lease",
                            icon: "doc.badge.plus",
                            color: .orange
                        ) {
                            createQuickDeal()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Property Matches
                    if !getMatchingProperties().isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Matching Warehouses")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(getMatchingProperties().prefix(3), id: \.property.id) { match in
                                PropertyMatchCard(match: match, lead: lead)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Deals Section
                    if !deals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Deals")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(deals) { deal in
                                DealSummaryRow(deal: deal)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Communications Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Communications")
                                .font(.headline)
                            Spacer()
                            Button("Add") {
                                showingAddCommunication = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        if communications.isEmpty {
                            Text("No communications yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(communications.prefix(10)) { communication in
                                CommunicationRow(communication: communication)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Prospect Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditLead = true
                    }
                }
            }
            .sheet(isPresented: $showingAddCommunication) {
                AddCommunicationView(leadId: lead.id)
            }
            .sheet(isPresented: $showingEditLead) {
                AddEditLeadView(lead: lead)
            }
        }
    }
    
    private func makeCall() {
        // Clean phone number for dialing
        let cleanPhone = lead.phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        // Open phone app first (more reliable)
        if let phoneURL = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(phoneURL) { success in
                if success {
                    // Only log communication if call was successfully initiated
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let communication = Communication(
                            leadId: self.lead.id, 
                            type: .phone, 
                            subject: "Phone Call", 
                            content: "Called \(self.lead.fullName) at \(self.lead.phone)"
                        )
                        self.dataManager.addCommunication(communication)
                    }
                } else {
                    print("❌ Failed to open phone app")
                }
            }
        } else {
            print("❌ Invalid phone number: \(lead.phone)")
        }
    }
    
    private func sendEmail() {
        // Open email app first
        if let emailURL = URL(string: "mailto:\(lead.email)?subject=Industrial%20Space%20Inquiry") {
            UIApplication.shared.open(emailURL) { success in
                if success {
                    // Only log communication if email was successfully opened
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let communication = Communication(
                            leadId: self.lead.id, 
                            type: .email, 
                            subject: "Follow-up Email", 
                            content: "Sent email to \(self.lead.email) regarding \(self.lead.formattedRequiredSF) requirement"
                        )
                        self.dataManager.addCommunication(communication)
                    }
                } else {
                    print("❌ Failed to open email app")
                }
            }
        } else {
            print("❌ Invalid email address: \(lead.email)")
        }
    }
    
    private func createQuickDeal() {
        // Auto-populate deal with prospect requirements
        let estimatedAnnualValue = lead.estimatedValue ?? Double(lead.requiredSquareFootage) * 8.0 // $8/SF default
        let deal = Deal(
            title: "\(lead.fullName) - \(lead.businessType.rawValue) Lease",
            leadId: lead.id,
            propertyId: nil,
            totalAnnualValue: Decimal(estimatedAnnualValue)
        )
        dataManager.addDeal(deal)
        
        // Log the deal creation
        let communication = Communication(
            leadId: lead.id,
            type: .note,
            subject: "Deal Created",
            content: "Created lease opportunity for \(lead.formattedRequiredSF)"
        )
        dataManager.addCommunication(communication)
    }
    
    private func getMatchingProperties() -> [PropertyMatch] {
        return MatchingEngine.findMatches(for: lead, in: dataManager.properties)
    }
    
    private func statusColor(for status: LeadStatus) -> Color {
        switch status {
        case .new: return .blue
        case .contacted: return .orange
        case .qualified: return .green
        case .negotiating: return .purple
        case .closed: return .mint
        case .dead: return .red
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

struct StatusBadge: View {
    let status: String
    let color: Color
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct DealSummaryRow: View {
    let deal: Deal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(deal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(deal.stage.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatCurrency(deal.value))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

struct CommunicationRow: View {
    let communication: Communication
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: iconForType(communication.type))
                        .foregroundColor(colorForType(communication.type))
                    Text(communication.subject)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(communication.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !communication.content.isEmpty {
                    Text(communication.content)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
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
    
    private func colorForType(_ type: CommunicationType) -> Color {
        switch type {
        case .email: return .blue
        case .phone: return .green
        case .text: return .purple
        case .meeting: return .orange
        case .note: return .gray
        }
    }
}

struct PropertyMatchCard: View {
    let match: PropertyMatch
    let lead: Lead
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(match.property.address)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(match.score))% match")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                HStack(spacing: 8) {
                    Text(match.property.formattedSquareFootage)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(match.property.formattedClearHeight)
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    if match.property.railAccess {
                        Image(systemName: "tram.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Text(match.reasons.joined(separator: " • "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("Create Lease") {
                    createDealWithProperty()
                }
                .font(.caption)
                .buttonStyle(.borderedProminent)
                
                Text(match.property.askingRate, format: .currency(code: "USD").precision(.fractionLength(2)))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func createDealWithProperty() {
        let annualValue = match.property.totalAnnualRent
        let deal = Deal(
            title: "\(lead.fullName) - \(match.property.address)",
            leadId: lead.id,
            propertyId: match.property.id,
            totalAnnualValue: annualValue
        )
        dataManager.addDeal(deal)
        
        // Log the match
        let communication = Communication(
            leadId: lead.id,
            type: .note,
            subject: "Property Matched",
            content: "Matched with \(match.property.address) - \(match.property.formattedSquareFootage)"
        )
        dataManager.addCommunication(communication)
    }
}

#Preview {
    LeadDetailView(lead: Lead(firstName: "John", lastName: "Smith", email: "john@example.com", phone: "(555) 123-4567", source: .website, businessType: .distribution, requiredSquareFootage: 50000))
        .environmentObject(DataManager.shared)
}
