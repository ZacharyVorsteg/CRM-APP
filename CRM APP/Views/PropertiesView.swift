//
//  PropertiesView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

struct PropertiesView: View {
    @EnvironmentObject var dataManager: DataManager
    
    // MARK: - Filter Types
    enum SizeRange: String, CaseIterable {
        case all = "All Sizes"
        case small = "Under 50K SF"
        case medium = "50K - 200K SF"
        case large = "200K - 500K SF"
        case xlarge = "Over 500K SF"
    }
    
    enum ClearHeightRange: String, CaseIterable {
        case all = "All Heights"
        case low = "Under 24'"
        case medium = "24' - 32'"
        case high = "Over 32'"
    }
    
    enum PropertySort: String, CaseIterable {
        case dateAdded = "Date Added"
        case size = "Size"
        case price = "Price"
        case location = "Location"
    }
    
    @State private var showingAddProperty = false
    @State private var selectedProperty: Property?
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var sizeFilter: SizeRange = .all
    @State private var clearHeightFilter: ClearHeightRange = .all
    @State private var railAccessOnly = false
    @State private var sortBy: PropertySort = .dateAdded
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search warehouses...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    Button("Filters") {
                        showingFilters = true
                    }
                    .foregroundColor(.accentColor)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Properties List
                if filteredProperties.isEmpty {
                    EmptyWarehousesState(
                        hasSearchTerm: !searchText.isEmpty,
                        onAddProperty: { showingAddProperty = true }
                    )
                } else {
                    List {
                        ForEach(filteredProperties, id: \.id) { property in
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
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Warehouses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
    }
    
    // MARK: - Computed Properties
    private var filteredProperties: [Property] {
        var properties = dataManager.properties
        
        // Apply search filter
        if !searchText.isEmpty {
            properties = properties.filter { property in
                property.address.localizedCaseInsensitiveContains(searchText) ||
                property.city.localizedCaseInsensitiveContains(searchText) ||
                property.state.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply size filter
        switch sizeFilter {
        case .all:
            break
        case .small:
            properties = properties.filter { $0.squareFootage < 50000 }
        case .medium:
            properties = properties.filter { $0.squareFootage >= 50000 && $0.squareFootage < 200000 }
        case .large:
            properties = properties.filter { $0.squareFootage >= 200000 && $0.squareFootage < 500000 }
        case .xlarge:
            properties = properties.filter { $0.squareFootage >= 500000 }
        }
        
        // Apply clear height filter
        switch clearHeightFilter {
        case .all:
            break
        case .low:
            properties = properties.filter { $0.clearHeight < 24.0 }
        case .medium:
            properties = properties.filter { $0.clearHeight >= 24.0 && $0.clearHeight <= 32.0 }
        case .high:
            properties = properties.filter { $0.clearHeight > 32.0 }
        }
        
        // Apply rail access filter
        if railAccessOnly {
            properties = properties.filter { $0.railAccess }
        }
        
        // Apply sorting
        switch sortBy {
        case .dateAdded:
            properties = properties.sorted { $0.dateAdded > $1.dateAdded }
        case .size:
            properties = properties.sorted { $0.squareFootage > $1.squareFootage }
        case .price:
            properties = properties.sorted { $0.askingRate < $1.askingRate }
        case .location:
            properties = properties.sorted { $0.city < $1.city }
        }
        
        return properties
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
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "building.2")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(hasSearchTerm ? "No warehouses found" : "No warehouses yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(hasSearchTerm ? "Try adjusting your search terms" : "Add your first warehouse to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if !hasSearchTerm {
                Button("Add Warehouse") {
                    onAddProperty()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Property Row
private struct PropertyRowView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
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
                    Text("$\(property.askingRate, specifier: "%.2f")/SF")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(property.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                }
            }
            
            // Specs
            HStack(spacing: 16) {
                SpecView(title: "SIZE", value: property.formattedSquareFootage, color: .blue)
                SpecView(title: "HEIGHT", value: property.formattedClearHeight, color: .green)
                SpecView(title: "DOCKS", value: "\(property.loadingDocks)", color: .orange)
                
                if property.railAccess {
                    Image(systemName: "tram")
                        .foregroundColor(.purple)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .accessibilityLabel("\(property.address) in \(property.city), \(property.formattedSquareFootage), \(property.formattedClearHeight) clear height")
    }
    
    private var statusColor: Color {
        switch property.status {
        case .available: return .green
        case .pending: return .orange
        case .leased: return .red
        }
    }
}

// MARK: - Spec View
private struct SpecView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    PropertiesView()
        .environmentObject(DataManager.shared)
}