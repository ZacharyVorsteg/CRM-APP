//
//  PropertiesView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

// MARK: - Design System Extensions
extension Color {
    static let primaryBlue = Color(red: 0.118, green: 0.227, blue: 0.541) // #1E3A8A
    static let secondaryEmerald = Color(red: 0.063, green: 0.725, blue: 0.506) // #10B981
    static let warningAmber = Color(red: 0.961, green: 0.620, blue: 0.043) // #F59E0B
    static let cardBackground = Color(.systemBackground).opacity(0.95)
    static let surfaceSecondary = Color(.secondarySystemBackground).opacity(0.05)
}

// MARK: - Elevation System
enum Elevation {
    case low, medium, high
    
    var shadow: some View {
        switch self {
        case .low:
            return Color.black.opacity(0.04).shadow(radius: 4)
        case .medium:
            return Color.black.opacity(0.06).shadow(radius: 8)
        case .high:
            return Color.black.opacity(0.08).shadow(radius: 12)
        }
    }
    
    var shadowModifier: some ViewModifier {
        switch self {
        case .low:
            return ShadowModifier(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        case .medium:
            return ShadowModifier(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        case .high:
            return ShadowModifier(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }
}

struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - Reusable Style Modifiers
struct CardStyle: ViewModifier {
    let elevation: Elevation
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(12)
                    )
            )
            .modifier(elevation.shadowModifier)
    }
}

struct StatusBadgeStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(color: Color.primaryBlue.opacity(0.25), radius: 8, x: 0, y: 3)
    }
}

extension View {
    func cardStyle(elevation: Elevation = .medium) -> some View {
        modifier(CardStyle(elevation: elevation))
    }
    
    func statusBadge(color: Color) -> some View {
        modifier(StatusBadgeStyle(color: color))
    }
    
    func primaryButton() -> some View {
        modifier(PrimaryButtonStyle())
    }
    
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: style)
            impactFeedback.impactOccurred()
        }
    }
}

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
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Enhanced Search Bar
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("Search warehouses...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.body)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .modifier(Elevation.low.shadowModifier)
                        
                        Button(action: { 
                            showingFilters = true
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primaryBlue)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .modifier(Elevation.low.shadowModifier)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                    // Properties List
                    if filteredProperties.isEmpty {
                        EmptyWarehousesState(
                            hasSearchTerm: !searchText.isEmpty,
                            onAddProperty: { showingAddProperty = true }
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredProperties, id: \.id) { property in
                                    PropertyRowView(property: property)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedProperty = property
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button("Edit") {
                                                selectedProperty = property
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                impactFeedback.impactOccurred()
                                            }
                                            .tint(.primaryBlue)
                                            
                                            Button("Archive") {
                                                archiveProperty(property)
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                impactFeedback.impactOccurred()
                                            }
                                            .tint(.warningAmber)
                                            
                                            Button("Delete", role: .destructive) {
                                                dataManager.deleteProperty(property)
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                                impactFeedback.impactOccurred()
                                            }
                                            .tint(.red)
                                        }
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: filteredProperties.count)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        }
                    }
                }
            }
            .navigationTitle("Warehouses")
            .navigationBarTitleDisplayMode(.large)
            .background(.ultraThinMaterial)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        showingAddProperty = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.primaryBlue)
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
        VStack(spacing: 32) {
            Spacer()
            
            // Enhanced Empty State Graphic
            ZStack {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 120, height: 120)
                    .modifier(Elevation.low.shadowModifier)
                
                Image(systemName: hasSearchTerm ? "magnifyingglass" : "building.2")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Text(hasSearchTerm ? "No warehouses found" : "No warehouses yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(hasSearchTerm ? "Try adjusting your search terms or filters" : "Add your first warehouse to get started with your industrial portfolio")
                    .font(.body)
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            if !hasSearchTerm {
                Button(action: {
                    onAddProperty()
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("Add Warehouse")
                            .fontWeight(.medium)
                    }
                }
                .primaryButton()
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hasSearchTerm)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.surfaceSecondary.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Property Row
private struct PropertyRowView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with enhanced typography
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(property.address)
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(property.city), \(property.state)")
                            .font(.footnote)
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Enhanced pricing display
                    Text("$\(Double(truncating: property.askingRate as NSNumber), specifier: "%.2f")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryBlue)
                    
                    Text("per SF/year")
                        .font(.caption)
                        .foregroundStyle(.secondary.opacity(0.7))
                    
                    // Status with enhanced badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(property.status.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .statusBadge(color: statusColor)
                }
            }
            
            // Enhanced specs with better visual hierarchy
            HStack(spacing: 20) {
                EnhancedSpecView(
                    title: "SIZE", 
                    value: property.formattedSquareFootage, 
                    icon: "square.grid.3x3",
                    color: .secondaryEmerald
                )
                
                EnhancedSpecView(
                    title: "HEIGHT", 
                    value: property.formattedClearHeight, 
                    icon: "arrow.up.and.down",
                    color: .primaryBlue
                )
                
                EnhancedSpecView(
                    title: "DOCKS", 
                    value: "\(property.loadingDocks)", 
                    icon: "truck.box",
                    color: .warningAmber
                )
                
                Spacer()
                
                if property.railAccess {
                    VStack(spacing: 4) {
                        Image(systemName: "tram.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("RAIL")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .cardStyle(elevation: .medium)
        .accessibilityLabel("\(property.address) in \(property.city), \(property.formattedSquareFootage), \(property.formattedClearHeight) clear height")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: property.status)
    }
    
    private var statusColor: Color {
        switch property.status {
        case .available: return .secondaryEmerald
        case .underLOI: return .warningAmber
        case .leased: return .red
        case .offMarket: return .secondary
        }
    }
}

// MARK: - Enhanced Spec View
private struct EnhancedSpecView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            
            Text(value)
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .cornerRadius(8)
        .modifier(Elevation.low.shadowModifier)
    }
}

#Preview {
    PropertiesView()
        .environmentObject(DataManager.shared)
}