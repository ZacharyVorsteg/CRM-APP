//
//  PropertiesView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

struct PropertiesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddProperty = false
    @State private var selectedProperty: Property?
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var sizeFilter: SizeRange = .all
    @State private var clearHeightFilter: ClearHeightRange = .all
    @State private var railAccessOnly = false
    @State private var sortBy: PropertySort = .dateAdded
    
    enum SizeRange: String, CaseIterable {
        case all = "All Sizes"
        case small = "< 25K SF"
        case medium = "25K - 50K SF"
        case large = "50K - 100K SF"
        case xlarge = "> 100K SF"
    }
    
    enum ClearHeightRange: String, CaseIterable {
        case all = "All Heights"
        case low = "< 24'"
        case medium = "24' - 32'"
        case high = "> 32'"
    }
    
    enum PropertySort: String, CaseIterable {
        case dateAdded = "Date Added"
        case size = "Size"
        case rate = "Rate"
        case daysOnMarket = "Days on Market"
    }
    
    var filteredProperties: [Property] {
        var filtered = dataManager.properties
        
        // Text search
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.address.localizedCaseInsensitiveContains(searchText) ||
                $0.city.localizedCaseInsensitiveContains(searchText) ||
                $0.zipCode.localizedCaseInsensitiveContains(searchText) ||
                $0.zoning.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Size filter
        switch sizeFilter {
        case .small:
            filtered = filtered.filter { $0.squareFootage < 25000 }
        case .medium:
            filtered = filtered.filter { $0.squareFootage >= 25000 && $0.squareFootage < 50000 }
        case .large:
            filtered = filtered.filter { $0.squareFootage >= 50000 && $0.squareFootage < 100000 }
        case .xlarge:
            filtered = filtered.filter { $0.squareFootage >= 100000 }
        case .all:
            break
        }
        
        // Clear height filter
        switch clearHeightFilter {
        case .low:
            filtered = filtered.filter { $0.clearHeight < 24 }
        case .medium:
            filtered = filtered.filter { $0.clearHeight >= 24 && $0.clearHeight <= 32 }
        case .high:
            filtered = filtered.filter { $0.clearHeight > 32 }
        case .all:
            break
        }
        
        // Rail access filter
        if railAccessOnly {
            filtered = filtered.filter { $0.railAccess }
        }
        
        // Sort
        switch sortBy {
        case .dateAdded:
            filtered = filtered.sorted { $0.dateAdded > $1.dateAdded }
        case .size:
            filtered = filtered.sorted { $0.squareFootage > $1.squareFootage }
        case .rate:
            filtered = filtered.sorted { $0.askingRate < $1.askingRate }
        case .daysOnMarket:
            filtered = filtered.sorted { $0.daysOnMarket > $1.daysOnMarket }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("Search warehouses...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                
                // Properties List
                if filteredProperties.isEmpty {
                    EmptyWarehousesState(
                        hasSearchTerm: !searchText.isEmpty,
                        onAddProperty: { showingAddProperty = true }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredProperties) { property in
                                PropertyRowView(property: property)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedProperty = property
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button("Edit") {
                                            selectedProperty = property
                                        }
                                        .tint(.blue)
                                        
                                        Button("Archive") {
                                            archiveProperty(property)
                                        }
                                        .tint(.orange)
                                        
                                        Button("Delete", role: .destructive) {
                                            dataManager.deleteProperty(property)
                                        }
                                        .tint(.red)
                                    }
                                    .accessibilityLabel("\(property.address), \(property.formattedSquareFootage), \(property.formattedClearHeight), \(property.status.rawValue)")
                                    .accessibilityHint("Tap to edit warehouse details")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Warehouses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProperty = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                PropertyFiltersView(
                    sizeFilter: $sizeFilter,
                    clearHeightFilter: $clearHeightFilter,
                    railAccessOnly: $railAccessOnly,
                    sortBy: $sortBy
                )
            }
            .sheet(isPresented: $showingAddProperty) {
                AddEditPropertyView(property: nil)
            }
        .sheet(item: $selectedProperty) { property in
            AddEditPropertyView(property: property)
        }
    }
    
    // MARK: - Helper Functions
    private func archiveProperty(_ property: Property) {
        var updatedProperty = property
        updatedProperty.status = .leased
        updatedProperty.description = "Archived \(Date().formatted(date: .abbreviated, time: .omitted)). \(updatedProperty.description)"
        
        dataManager.updateProperty(updatedProperty)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Empty State
private struct EmptyWarehousesState: View {
    let hasSearchTerm: Bool
    let onAddProperty: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(hasSearchTerm ? "No warehouses found" : "No warehouses yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(hasSearchTerm ? "Try different search terms or filters" : "Add your first warehouse to start managing inventory")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !hasSearchTerm {
                Button("Add Warehouse") {
                    onAddProperty()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Creates a new warehouse listing")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(hasSearchTerm ? "No warehouse search results" : "No warehouses available")
    }
}

struct PropertyRowView: View {
    let property: Property
    
    var body: some View {
        VStack(spacing: 14) {
            // Header Row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.address)
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                    
                    Text("\(property.city), \(property.state)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(property.status.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(for: property.status))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    Text("\(property.daysOnMarket) days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Specs Row
            HStack {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SIZE")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(property.formattedSquareFootage)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HEIGHT")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(property.formattedClearHeight)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DOCKS")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("\(property.loadingDocks)")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    if property.railAccess {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("RAIL")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(property.askingRate, format: .currency(code: "USD").precision(.fractionLength(2)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("per SF/Year")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Zoning and Availability
            HStack {
                Text(property.zoning.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(6)
                
                Spacer()
                
                Text("Available: \(property.availableDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    private func statusColor(for status: PropertyStatus) -> Color {
        switch status {
        case .available: return .green
        case .underLOI: return .orange
        case .leased: return .blue
        case .offMarket: return .red
        }
    }
}

#Preview {
    PropertiesView()
        .environmentObject(DataManager.shared)
}
