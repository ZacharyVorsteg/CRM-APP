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
    
    var isEditing: Bool {
        property != nil
    }
    
    var isFormValid: Bool {
        !address.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty && 
        !squareFootage.isEmpty && !clearHeight.isEmpty && !askingRate.isEmpty &&
        Int(squareFootage) != nil && Double(clearHeight) != nil && Decimal(string: askingRate) != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Property Address") {
                    TextField("Street Address", text: $address)
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                    TextField("ZIP Code", text: $zipCode)
                        .keyboardType(.numberPad)
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
            .navigationTitle(isEditing ? "Edit Property" : "New Property")
            .navigationBarTitleDisplayMode(.inline)
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
        return true
    }
}

#Preview {
    AddEditPropertyView(property: nil)
        .environmentObject(DataManager.shared)
}
