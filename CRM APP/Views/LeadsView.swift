//
//  LeadsView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct LeadsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddLead = false
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var filteredResults: [Lead] = []
    @State private var selectedStatus: LeadStatus?
    
    var filteredLeads: [Lead] {
        filteredResults.isEmpty && searchText.isEmpty ? 
            dataManager.leads.sorted { $0.dateCreated > $1.dateCreated } : 
            filteredResults
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.bottom, 8)
                    .onChange(of: searchText) { _, newValue in
                        applySearchFilter(newValue)
                    }
                
                // Quick Filter Chips
                StatusFilterChips(
                    selectedStatus: $selectedStatus,
                    statusCounts: getStatusCounts(),
                    onClear: clearFilters
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Leads List
                if filteredLeads.isEmpty {
                    EmptyProspectsState(
                        hasSearchTerm: !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        onAddProspect: { showingAddLead = true }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredLeads) { lead in
                                NavigationLink(destination: LeadDetailView(lead: lead)) {
                                    LeadRowView(
                                        lead: lead,
                                        onCall: quickCall,
                                        onEmail: quickEmail
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(Rectangle())
                                .swipeActions(edge: .trailing) {
                                    Button("Qualified") {
                                        hapticFeedback()
                                        markAsQualified(lead)
                                    }
                                    .tint(Color.secondaryEmerald)
                                    
                                    Button("Archive") {
                                        hapticFeedback()
                                        archiveProspect(lead)
                                    }
                                    .tint(Color.warningAmber)
                                    
                                    Button("Delete", role: .destructive) {
                                        hapticFeedback()
                                        dataManager.deleteLead(lead)
                                    }
                                    .tint(.red)
                                }
                                .accessibilityLabel("\(lead.fullName), \(lead.businessType.rawValue), \(lead.formattedRequiredSF), \(lead.status.rawValue)")
                                .accessibilityHint("Tap to view prospect details")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Prospects")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                filteredResults = dataManager.leads.sorted { $0.dateCreated > $1.dateCreated }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddLead = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLead) {
                AddEditLeadView(lead: nil)
            }
        }
    }
    
    
    // MARK: - Quick Actions
    private func quickCall(_ lead: Lead) {
        let cleanPhone = lead.phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        if let phoneURL = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(phoneURL) { success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let communication = Communication(
                            leadId: lead.id,
                            type: .phone,
                            subject: "Quick Call",
                            content: "Called \(lead.fullName) from prospect list"
                        )
                        self.dataManager.addCommunication(communication)
                    }
                }
            }
        }
    }
    
    private func quickEmail(_ lead: Lead) {
        if let emailURL = URL(string: "mailto:\(lead.email)?subject=Industrial%20Space%20Follow-up") {
            UIApplication.shared.open(emailURL) { success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let communication = Communication(
                            leadId: lead.id,
                            type: .email,
                            subject: "Follow-up Email",
                            content: "Sent email follow-up to \(lead.fullName)"
                        )
                        self.dataManager.addCommunication(communication)
                    }
                }
            }
        }
    }
    
    private func markAsQualified(_ lead: Lead) {
        var updatedLead = lead
        updatedLead.status = .qualified
        dataManager.updateLead(updatedLead)
        
        // Auto-create communication log
        let communication = Communication(
            leadId: lead.id,
            type: .note,
            subject: "Marked as Qualified",
            content: "Prospect qualified for \(lead.formattedRequiredSF)"
        )
        dataManager.addCommunication(communication)
    }
    
    private func findMatchingProperties(_ lead: Lead) {
        // This would show matching properties - for now just a placeholder
        // In a future version, this could open a filtered property list
    }
    
    private func hapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func archiveProspect(_ lead: Lead) {
        var updatedLead = lead
        updatedLead.status = .dead
        updatedLead.notes = "Archived \(Date().formatted(date: .abbreviated, time: .omitted)). \(updatedLead.notes)"
        
        dataManager.updateLead(updatedLead)
    }
    
    // MARK: - Search
    private func applySearchFilter(_ searchTerm: String) {
        searchTask?.cancel()
        
        let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 220_000_000) // ~0.22s
            
            if Task.isCancelled { return }
            
            await MainActor.run {
                var results = dataManager.leads
                
                // Apply status filter first
                if let status = selectedStatus {
                    results = results.filter { $0.status == status }
                }
                
                // Apply search filter
                if trimmed.count >= 2 {
                    results = results.filter {
                        $0.fullName.localizedCaseInsensitiveContains(trimmed) ||
                        $0.email.localizedCaseInsensitiveContains(trimmed) ||
                        $0.phone.localizedCaseInsensitiveContains(trimmed) ||
                        $0.businessType.rawValue.localizedCaseInsensitiveContains(trimmed)
                    }
                }
                
                filteredResults = results.sorted { $0.dateCreated > $1.dateCreated }
            }
        }
    }
    
    // MARK: - Filter Helpers
    private func getStatusCounts() -> [LeadStatus: Int] {
        Dictionary(grouping: dataManager.leads) { $0.status }
            .mapValues { $0.count }
    }
    
    private func clearFilters() {
        selectedStatus = nil
        searchText = ""
        filteredResults = dataManager.leads.sorted { $0.dateCreated > $1.dateCreated }
    }
}

// MARK: - Status Filter Chips
private struct StatusFilterChips: View {
    @Binding var selectedStatus: LeadStatus?
    let statusCounts: [LeadStatus: Int]
    let onClear: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Clear chip
                Button("Clear") {
                    onClear()
                }
                .font(.footnote)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(selectedStatus == nil ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(selectedStatus == nil ? .white : .primary)
                .clipShape(Capsule())
                
                ForEach(LeadStatus.allCases, id: \.self) { status in
                    let count = statusCounts[status] ?? 0
                    if count > 0 {
                        Button("\(status.rawValue) (\(count))") {
                            selectedStatus = selectedStatus == status ? nil : status
                        }
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(selectedStatus == status ? Color.accentColor : Color(.systemGray5))
                        .foregroundColor(selectedStatus == status ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Empty State
private struct EmptyProspectsState: View {
    let hasSearchTerm: Bool
    let onAddProspect: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(hasSearchTerm ? "No matches found" : "No prospects yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(hasSearchTerm ? "Try adjusting your search terms" : "Add your first prospect to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !hasSearchTerm {
                Button("Add Prospect") {
                    onAddProspect()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Creates a new prospect entry")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(hasSearchTerm ? "No search results found" : "No prospects available")
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
            
            TextField("Search prospects...", text: $text)
                .textFieldStyle(.plain)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

struct LeadRowView: View {
    let lead: Lead
    @EnvironmentObject var dataManager: DataManager
    let onCall: (Lead) -> Void
    let onEmail: (Lead) -> Void
    
    private var matchSummary: String {
        MatchingEngine.getMatchSummary(for: lead, in: dataManager.properties)
    }
    
    private var urgencyIndicator: (String, Color)? {
        if lead.expansionTimeline == .immediate {
            return ("URGENT", .red)
        } else if let moveDate = lead.targetMoveDate, moveDate <= Date().addingTimeInterval(30 * 24 * 3600) {
            return ("SOON", .orange)
        } else if lead.lastContactDate == nil || lead.lastContactDate! < Date().addingTimeInterval(-7 * 24 * 3600) {
            return ("FOLLOW UP", .yellow)
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            Circle()
                .fill(statusColor(for: lead.status))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 6) {
                    // Name and urgency
                    HStack {
                        Text(lead.fullName)
                            .font(.body)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                        
                        Spacer()
                        
                        if let (urgencyText, urgencyColor) = urgencyIndicator {
                            Text(urgencyText)
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(urgencyColor)
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Business type, requirements, and budget
                    HStack(spacing: 12) {
                        // Business type
                        Text(lead.businessType.rawValue)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        // Required space
                        Text(lead.formattedRequiredSF)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        if lead.shift24Hour {
                            Text("• 24/7")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Budget - Featured prominently
                        Text(lead.formattedTotalBudget)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color.warningAmber)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.warningAmber.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    
                    // Timeline and match info
                    HStack {
                        Text(lead.expansionTimeline.rawValue)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        if !matchSummary.isEmpty && matchSummary != "No matches found" {
                            Text(matchSummary)
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                                .fontWeight(.medium)
                        }
                    }
                }
            
            // Quick Action Buttons
            VStack(spacing: 8) {
                Button(action: { onCall(lead) }) {
                    Image(systemName: "phone.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                
                Button(action: { onEmail(lead) }) {
                    Image(systemName: "envelope.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(urgencyIndicator?.1.opacity(0.3) ?? Color(.systemGray4), lineWidth: 1)
        )
        .cornerRadius(12)
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

#Preview {
    LeadsView()
        .environmentObject(DataManager.shared)
}
