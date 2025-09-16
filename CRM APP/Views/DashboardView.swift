//
//  DashboardView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingQuickAdd = false
    @State private var showingQuickCall = false
    @State private var showingAddProperty = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Key Metrics Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        MetricCard(
                            title: "Active Requirements",
                            value: formatSquareFootage(getActiveRequirements()),
                            icon: "building.2.fill",
                            color: .blue
                        )
                        
                        MetricCard(
                            title: "Available Inventory",
                            value: formatSquareFootage(getAvailableInventory()),
                            icon: "square.grid.3x3.fill",
                            color: .green
                        )
                        
                        MetricCard(
                            title: "Pipeline Value",
                            value: formatCurrency(getPipelineValue()),
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange
                        )
                        
                        MetricCard(
                            title: "Avg Days on Market",
                            value: "\(getAverageDaysOnMarket())",
                            icon: "calendar.badge.clock",
                            color: .purple
                        )
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickActionCard(
                                title: "Add Prospect",
                                icon: "person.badge.plus",
                                color: .blue
                            ) {
                                showingQuickAdd = true
                            }
                            
                            QuickActionCard(
                                title: "Log Call",
                                icon: "phone.badge.plus",
                                color: .green
                            ) {
                                showingQuickCall = true
                            }
                            
                            QuickActionCard(
                                title: "Add Warehouse",
                                icon: "building.2.badge.plus",
                                color: .orange
                            ) {
                                showingAddProperty = true
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Urgent Items
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Needs Attention")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if getUrgentProspects().isEmpty && getExpiringSoonProperties().isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.green)
                                Text("All caught up!")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("No urgent items need attention")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Today's Priority Actions
                    if !getTodaysPriorities().isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Priorities")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(getTodaysPriorities(), id: \.id) { priority in
                                    PriorityActionCard(priority: priority)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
        .sheet(isPresented: $showingQuickAdd) {
            QuickAddProspectView()
        }
        .sheet(isPresented: $showingAddProperty) {
            AddEditPropertyView(property: nil)
        }
        .sheet(isPresented: $showingQuickCall) {
            QuickCallLogView()
        }
    }
    
    // MARK: - Industrial Metrics Calculations
    private func getActiveRequirements() -> Int {
        return dataManager.leads
            .filter { $0.status == .qualified || $0.status == .contacted }
            .reduce(0) { $0 + $1.requiredSquareFootage }
    }
    
    private func getAvailableInventory() -> Int {
        let ninetyDaysFromNow = Date().addingTimeInterval(90 * 24 * 3600)
        return dataManager.properties
            .filter { $0.status == .available && $0.availableDate <= ninetyDaysFromNow }
            .reduce(0) { $0 + $1.squareFootage }
    }
    
    private func getPipelineValue() -> Double {
        let pipelineDeals = dataManager.deals.filter { 
            $0.stage != .initialInquiry && $0.stage != .occupied && $0.stage != .lost 
        }
        return pipelineDeals.reduce(0.0) { $0 + Double(truncating: $1.totalAnnualValue as NSNumber) }
    }
    
    private func getAverageDaysOnMarket() -> Int {
        let availableProperties = dataManager.properties.filter { $0.status == .available }
        guard !availableProperties.isEmpty else { return 0 }
        
        let totalDays = availableProperties.reduce(0) { $0 + $1.daysOnMarket }
        return totalDays / availableProperties.count
    }
    
    private func formatSquareFootage(_ sf: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let thousands = Double(sf) / 1000.0
        
        if thousands >= 1000 {
            return String(format: "%.1fM SF", thousands / 1000.0)
        } else if thousands >= 1 {
            return String(format: "%.0fK SF", thousands)
        } else {
            return "\(sf) SF"
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "$0"
        }
    }
    
    // MARK: - Smart Data Functions
    private func getUrgentProspects() -> [Lead] {
        let urgentCutoff = Date().addingTimeInterval(-7 * 24 * 3600)
        return dataManager.leads.filter { lead in
            (lead.lastContactDate == nil || lead.lastContactDate! < urgentCutoff) ||
            lead.expansionTimeline == .immediate ||
            (lead.targetMoveDate != nil && lead.targetMoveDate! <= Date().addingTimeInterval(30 * 24 * 3600))
        }.prefix(3).map { $0 }
    }
    
    private func getExpiringSoonProperties() -> [Property] {
        return dataManager.properties.filter { property in
            property.status == .available && property.daysOnMarket > 90
        }.prefix(2).map { $0 }
    }
    
    private func getTodaysPriorities() -> [PriorityAction] {
        var priorities: [PriorityAction] = []
        
        // Urgent prospects (immediate timeline or overdue follow-up)
        let urgentProspects = dataManager.leads.filter { lead in
            lead.expansionTimeline == .immediate || 
            (lead.lastContactDate == nil || lead.lastContactDate! < Date().addingTimeInterval(-7 * 24 * 3600))
        }
        
        for prospect in urgentProspects.prefix(3) {
            priorities.append(PriorityAction(
                id: UUID(),
                title: "Follow up with \(prospect.fullName)",
                subtitle: prospect.expansionTimeline == .immediate ? "Immediate timeline" : "Overdue contact",
                type: .call,
                urgency: .high,
                leadId: prospect.id
            ))
        }
        
        // Properties needing attention
        let staleProperties = dataManager.properties.filter { $0.daysOnMarket > 120 }
        for property in staleProperties.prefix(2) {
            priorities.append(PriorityAction(
                id: UUID(),
                title: "Review pricing for \(property.address)",
                subtitle: "\(property.daysOnMarket) days on market",
                type: .review,
                urgency: .medium,
                propertyId: property.id
            ))
        }
        
        return priorities.sorted { $0.urgency.rawValue < $1.urgency.rawValue }
    }
}

struct PriorityAction: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let type: ActionType
    let urgency: Urgency
    let leadId: UUID?
    let propertyId: UUID?
    
    init(id: UUID, title: String, subtitle: String, type: ActionType, urgency: Urgency, leadId: UUID? = nil, propertyId: UUID? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.urgency = urgency
        self.leadId = leadId
        self.propertyId = propertyId
    }
    
    enum ActionType {
        case call, email, review, followUp
        
        var icon: String {
            switch self {
            case .call: return "phone.fill"
            case .email: return "envelope.fill"
            case .review: return "doc.text.magnifyingglass"
            case .followUp: return "arrow.clockwise"
            }
        }
        
        var color: Color {
            switch self {
            case .call: return .green
            case .email: return .blue
            case .review: return .orange
            case .followUp: return .purple
            }
        }
    }
    
    enum Urgency: Int {
        case high = 1, medium = 2, low = 3
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }
}

struct PriorityActionCard: View {
    let priority: PriorityAction
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            Circle()
                .fill(priority.urgency.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(priority.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(priority.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { handlePriorityAction() }) {
                Image(systemName: priority.type.icon)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(priority.type.color)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(priority.urgency.color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func handlePriorityAction() {
        if let leadId = priority.leadId,
           let lead = dataManager.getLead(by: leadId) {
            
            switch priority.type {
            case .call:
                makeCall(to: lead)
            case .email:
                sendEmail(to: lead)
            case .followUp:
                markForFollowUp(lead)
            default:
                break
            }
        }
    }
    
    private func makeCall(to lead: Lead) {
        let cleanPhone = lead.phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        if let phoneURL = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(phoneURL)
        }
    }
    
    private func sendEmail(to lead: Lead) {
        if let emailURL = URL(string: "mailto:\(lead.email)?subject=Industrial%20Space%20Priority%20Follow-up") {
            UIApplication.shared.open(emailURL)
        }
    }
    
    private func markForFollowUp(_ lead: Lead) {
        var updatedLead = lead
        updatedLead.status = .contacted
        dataManager.updateLead(updatedLead)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                    .frame(width: 24, height: 24)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


#Preview {
    DashboardView()
        .environmentObject(DataManager.shared)
}
