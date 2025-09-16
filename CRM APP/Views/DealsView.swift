//
//  DealsView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

struct DealsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddDeal = false
    @State private var selectedDeal: Deal?
    @State private var selectedStage: DealStage?
    
    var groupedDeals: [DealStage: [Deal]] {
        Dictionary(grouping: dataManager.deals) { $0.stage }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Stage Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StageFilterButton(
                            stage: nil,
                            selectedStage: $selectedStage,
                            title: "All",
                            count: dataManager.deals.count
                        )
                        
                        ForEach(DealStage.allCases, id: \.self) { stage in
                            let count = groupedDeals[stage]?.count ?? 0
                            if count > 0 {
                                StageFilterButton(
                                    stage: stage,
                                    selectedStage: $selectedStage,
                                    title: stage.rawValue,
                                    count: count
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Deals List
                if filteredDeals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text(dataManager.deals.isEmpty ? "No deals yet" : "No deals in this stage")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text(dataManager.deals.isEmpty ? "Create your first deal to start tracking your pipeline" : "Try selecting a different stage filter")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if dataManager.deals.isEmpty {
                            Button("Add Deal") {
                                showingAddDeal = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredDeals) { deal in
                                DealRowView(deal: deal, dataManager: dataManager)
                                    .onTapGesture {
                                        selectedDeal = deal
                                    }
                                    .contextMenu {
                                        Button("Edit") {
                                            selectedDeal = deal
                                        }
                                        
                                        Button("Delete", role: .destructive) {
                                            dataManager.deleteDeal(deal)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Leases")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDeal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDeal) {
                AddEditDealView(deal: nil)
            }
            .sheet(item: $selectedDeal) { deal in
                AddEditDealView(deal: deal)
            }
        }
    }
    
    private var filteredDeals: [Deal] {
        if let selectedStage = selectedStage {
            return dataManager.deals.filter { $0.stage == selectedStage }
        } else {
            return dataManager.deals
        }
    }
    
}

struct StageFilterButton: View {
    let stage: DealStage?
    @Binding var selectedStage: DealStage?
    let title: String
    let count: Int
    
    var isSelected: Bool {
        selectedStage == stage
    }
    
    var body: some View {
        Button(action: {
            selectedStage = stage
        }) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("(\(count))")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct DealRowView: View {
    let deal: Deal
    let dataManager: DataManager
    
    var leadName: String {
        if let lead = dataManager.getLead(by: deal.leadId) {
            return lead.fullName
        }
        return "Unknown Lead"
    }
    
    var propertyAddress: String? {
        if let propertyId = deal.propertyId,
           let property = dataManager.getProperty(by: propertyId) {
            return property.address
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Header Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(deal.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text(leadName)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(deal.stage.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(stageColor(for: deal.stage))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    Text("\(deal.probability)%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Financial Row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ANNUAL VALUE")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Text(deal.totalAnnualValue, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("TERM")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Text(deal.formattedTermLength)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // Property and Timeline
            HStack {
                if let address = propertyAddress {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                } else {
                    Text("No property assigned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
                
                if let closeDate = deal.expectedCloseDate {
                    Text("Expected: \(closeDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    private func stageColor(for stage: DealStage) -> Color {
        switch stage {
        case .initialInquiry: return .blue
        case .siteTour: return .cyan
        case .loiSubmitted: return .orange
        case .loiNegotiation: return .purple
        case .leaseDraft: return .indigo
        case .dueDiligence: return .mint
        case .leaseExecution: return .green
        case .pendingOccupancy: return .teal
        case .occupied: return .green
        case .lost: return .red
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
    DealsView()
        .environmentObject(DataManager.shared)
}
