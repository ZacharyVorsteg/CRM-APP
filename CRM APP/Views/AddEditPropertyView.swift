//
//  AddEditPropertyView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct AddEditPropertyView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let property: Property?
    
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var status = PropertyStatus.available
    @State private var squareFootage = ""
    @State private var clearHeight = ""
    @State private var askingRate = ""
    @State private var loadingDocks = 0
    @State private var powerCapacity = ""
    @State private var zoning = ZoningType.lightIndustrial
    @State private var sprinklerSystem = SprinklerSystem.wet
    @State private var columnSpacing = ""
    @State private var truckCourtDepth = 130
    @State private var railAccess = false
    @State private var craneCapacity = ""
    @State private var officeSquareFootage = ""
    @State private var yardSize = ""
    @State private var ceilingType = ""
    @State private var yearBuilt = ""
    @State private var availableDate = Date()
    @State private var description = ""
    @State private var hasUnsavedChanges = false
    @FocusState private var focusedField: PropertyField?
    @AppStorage("lastPropertyCity") private var lastCity = ""
    @AppStorage("lastPropertyState") private var lastState = ""
    
    var isEditing: Bool {
        property != nil
    }
    
    var isFormValid: Bool {
        !address.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty && 
        !squareFootage.isEmpty && !clearHeight.isEmpty && !askingRate.isEmpty &&
        Int(squareFootage) != nil && Double(clearHeight) != nil && Decimal(string: askingRate) != nil
    }
    
    enum PropertyField {
        case address, city, state, zipCode, squareFootage, clearHeight, askingRate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Property Address") {
                    VStack(alignment: .leading, spacing: 4) {
                        if UIPasteboard.general.hasStrings, let pasteText = UIPasteboard.general.string, looksLikeAddress(pasteText) {
                            Button("📋 Paste Address") {
                                parseAndFillAddress(pasteText)
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        }
                        
                        TextField("Street Address", text: $address)
                            .focused($focusedField, equals: .address)
                            .textContentType(.streetAddressLine1)
                            .onChange(of: address) { _ in hasUnsavedChanges = true }
                        
                        HStack {
                            TextField("City", text: $city)
                                .focused($focusedField, equals: .city)
                                .textContentType(.addressCity)
                                .onChange(of: city) { _ in hasUnsavedChanges = true }
                            
                            TextField("State", text: $state)
                                .focused($focusedField, equals: .state)
                                .textContentType(.addressState)
                                .onChange(of: state) { _ in hasUnsavedChanges = true }
                        }
                        
                        TextField("ZIP Code", text: $zipCode)
                            .focused($focusedField, equals: .zipCode)
                            .keyboardType(.numberPad)
                            .textContentType(.postalCode)
                            .onChange(of: zipCode) { _ in hasUnsavedChanges = true }
                    }
                }
                
                Section("Warehouse Specifications") {
                    TextField("Square Footage", text: $squareFootage)
                        .keyboardType(.numberPad)
                    
                    TextField("Clear Height (feet)", text: $clearHeight)
                        .keyboardType(.decimalPad)
                    
                    Stepper("Loading Docks: \(loadingDocks)", value: $loadingDocks, in: 0...50)
                    
                    TextField("Column Spacing", text: $columnSpacing)
                        .placeholder(when: columnSpacing.isEmpty) {
                            Text("e.g., 40' x 50'")
                        }
                    
                    TextField("Truck Court Depth (feet)", value: $truckCourtDepth, format: .number)
                        .keyboardType(.numberPad)
                    
                    Toggle("Rail Access", isOn: $railAccess)
                    
                    TextField("Crane Capacity (optional)", text: $craneCapacity)
                        .placeholder(when: craneCapacity.isEmpty) {
                            Text("e.g., 5 ton bridge crane")
                        }
                }
                
                Section("Infrastructure & Utilities") {
                    TextField("Power Capacity", text: $powerCapacity)
                        .placeholder(when: powerCapacity.isEmpty) {
                            Text("e.g., 480V/3-phase/2000 amps")
                        }
                    
                    Picker("Sprinkler System", selection: $sprinklerSystem) {
                        ForEach(SprinklerSystem.allCases, id: \.self) { system in
                            Text(system.rawValue).tag(system)
                        }
                    }
                    
                    Picker("Zoning", selection: $zoning) {
                        ForEach(ZoningType.allCases, id: \.self) { zone in
                            Text(zone.rawValue).tag(zone)
                        }
                    }
                    
                    TextField("Ceiling Type", text: $ceilingType)
                        .placeholder(when: ceilingType.isEmpty) {
                            Text("e.g., Concrete Tilt-Up")
                        }
                    
                    TextField("Year Built", text: $yearBuilt)
                        .keyboardType(.numberPad)
                }
                
                Section("Office & Yard") {
                    TextField("Office Square Footage", text: $officeSquareFootage)
                        .keyboardType(.numberPad)
                    
                    TextField("Yard Size (square feet)", text: $yardSize)
                        .keyboardType(.numberPad)
                }
                
                Section("Lease Terms") {
                    Picker("Status", selection: $status) {
                        ForEach(PropertyStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("Asking Rate ($/SF/Year)", text: $askingRate)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Available Date", selection: $availableDate, displayedComponents: .date)
                }
                
                Section("Description") {
                    TextField("Property Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Warehouse" : "New Warehouse")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if hasUnsavedChanges {
                    StickySaveBar(
                        isValid: isFormValid,
                        onSave: { 
                            if validateAndSave() {
                                hasUnsavedChanges = false
                            }
                        },
                        onCancel: { dismiss() }
                    )
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Previous") {
                        focusPreviousField()
                    }
                    .disabled(focusedField == .address)
                    
                    Button("Next") {
                        focusNextField()
                    }
                    .disabled(focusedField == .askingRate)
                    
                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if validateAndSave() {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .onAppear {
            if let property = property {
                loadPropertyData(property)
            } else {
                // Prefill city/state for new properties
                if city.isEmpty && !lastCity.isEmpty {
                    city = lastCity
                }
                if state.isEmpty && !lastState.isEmpty {
                    state = lastState
                }
            }
        }
    }
    
    private func loadPropertyData(_ property: Property) {
        address = property.address
        city = property.city
        state = property.state
        zipCode = property.zipCode
        status = property.status
        squareFootage = String(property.squareFootage)
        clearHeight = String(property.clearHeight)
        askingRate = String(describing: property.askingRate)
        loadingDocks = property.loadingDocks
        powerCapacity = property.powerCapacity
        zoning = property.zoning
        sprinklerSystem = property.sprinklerSystem
        columnSpacing = property.columnSpacing
        truckCourtDepth = property.truckCourtDepth
        railAccess = property.railAccess
        craneCapacity = property.craneCapacity ?? ""
        officeSquareFootage = String(property.officeSquareFootage)
        yardSize = String(property.yardSize)
        ceilingType = property.ceilingType
        yearBuilt = property.yearBuilt?.description ?? ""
        availableDate = property.availableDate
        description = property.description
    }
    
    private func saveProperty() {
        guard let sf = Int(squareFootage),
              let height = Double(clearHeight),
              let rate = Decimal(string: askingRate) else { return }
        
        if let existingProperty = property {
            // Update existing property
            var updatedProperty = existingProperty
            updatedProperty.address = address
            updatedProperty.city = city
            updatedProperty.state = state
            updatedProperty.zipCode = zipCode
            updatedProperty.status = status
            updatedProperty.squareFootage = sf
            updatedProperty.clearHeight = height
            updatedProperty.askingRate = rate
            updatedProperty.loadingDocks = loadingDocks
            updatedProperty.powerCapacity = powerCapacity.isEmpty ? "TBD" : powerCapacity
            updatedProperty.zoning = zoning
            updatedProperty.sprinklerSystem = sprinklerSystem
            updatedProperty.columnSpacing = columnSpacing.isEmpty ? "TBD" : columnSpacing
            updatedProperty.truckCourtDepth = truckCourtDepth
            updatedProperty.railAccess = railAccess
            updatedProperty.craneCapacity = craneCapacity.isEmpty ? nil : craneCapacity
            updatedProperty.officeSquareFootage = Int(officeSquareFootage) ?? 0
            updatedProperty.yardSize = Int(yardSize) ?? 0
            updatedProperty.ceilingType = ceilingType.isEmpty ? "Concrete Tilt-Up" : ceilingType
            updatedProperty.yearBuilt = Int(yearBuilt)
            updatedProperty.availableDate = availableDate
            updatedProperty.description = description
            
            dataManager.updateProperty(updatedProperty)
        } else {
            // Create new property
            var newProperty = Property(
                address: address,
                city: city,
                state: state,
                zipCode: zipCode,
                squareFootage: sf,
                clearHeight: height,
                askingRate: rate
            )
            newProperty.status = status
            newProperty.loadingDocks = loadingDocks
            newProperty.powerCapacity = powerCapacity.isEmpty ? "TBD" : powerCapacity
            newProperty.zoning = zoning
            newProperty.sprinklerSystem = sprinklerSystem
            newProperty.columnSpacing = columnSpacing.isEmpty ? "TBD" : columnSpacing
            newProperty.truckCourtDepth = truckCourtDepth
            newProperty.railAccess = railAccess
            newProperty.craneCapacity = craneCapacity.isEmpty ? nil : craneCapacity
            newProperty.officeSquareFootage = Int(officeSquareFootage) ?? 0
            newProperty.yardSize = Int(yardSize) ?? 0
            newProperty.ceilingType = ceilingType.isEmpty ? "Concrete Tilt-Up" : ceilingType
            newProperty.yearBuilt = Int(yearBuilt)
            newProperty.availableDate = availableDate
            newProperty.description = description
            
            dataManager.addProperty(newProperty)
        }
        
        dismiss()
    }
    
    private func validateAndSave() -> Bool {
        guard let sf = Int(squareFootage),
              let height = Double(clearHeight),
              let rate = Decimal(string: askingRate) else { 
            return false
        }
        
        // Validation checks
        guard sf > 0 && sf <= 10_000_000 else { return false }
        guard height > 0 && height <= 100 else { return false }
        guard rate > 0 && rate <= 100 else { return false }
        
        saveProperty()
        
        // Remember city/state for next time
        lastCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        lastState = state.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return true
    }
    
    // MARK: - Address Parsing
    private func looksLikeAddress(_ text: String) -> Bool {
        let addressPattern = #"^\d+\s+[A-Za-z\s]+,?\s*[A-Za-z\s]+,?\s*[A-Z]{2}\s*\d{5}"#
        return text.range(of: addressPattern, options: .regularExpression) != nil
    }
    
    private func parseAndFillAddress(_ text: String) {
        guard let parsed = parseAddress(text) else { return }
        
        address = parsed.street
        city = parsed.city
        state = parsed.state
        zipCode = parsed.zip
        hasUnsavedChanges = true
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func parseAddress(_ text: String) -> ParsedAddress? {
        // Simple regex-based parsing
        let components = text.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        guard components.count >= 3 else { return nil }
        
        let street = components[0]
        let city = components[1]
        let stateZip = components[2].components(separatedBy: " ")
        
        guard stateZip.count >= 2 else { return nil }
        
        let state = stateZip[0]
        let zip = stateZip[1]
        
        return ParsedAddress(street: street, city: city, state: state, zip: zip)
    }
    
    // MARK: - Focus Management
    private func focusNextField() {
        switch focusedField {
        case .address: focusedField = .city
        case .city: focusedField = .state
        case .state: focusedField = .zipCode
        case .zipCode: focusedField = .squareFootage
        case .squareFootage: focusedField = .clearHeight
        case .clearHeight: focusedField = .askingRate
        case .askingRate: focusedField = nil
        case .none: focusedField = .address
        }
    }
    
    private func focusPreviousField() {
        switch focusedField {
        case .askingRate: focusedField = .clearHeight
        case .clearHeight: focusedField = .squareFootage
        case .squareFootage: focusedField = .zipCode
        case .zipCode: focusedField = .state
        case .state: focusedField = .city
        case .city: focusedField = .address
        case .address: focusedField = nil
        case .none: focusedField = .askingRate
        }
    }
}

// MARK: - Helper Structures
private struct ParsedAddress {
    let street: String
    let city: String
    let state: String
    let zip: String
}

private struct StickySaveBar: View {
    let isValid: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            Button("Cancel") {
                onCancel()
            }
            .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Save") {
                onSave()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isValid)
        }
        .padding()
        .background(.regularMaterial)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    AddEditPropertyView(property: nil)
        .environmentObject(DataManager.shared)
}
