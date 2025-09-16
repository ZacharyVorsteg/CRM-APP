//
//  AddEditLeadView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct AddEditLeadView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let lead: Lead?
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var status = LeadStatus.new
    @State private var source = LeadSource.website
    @State private var notes = ""
    @State private var estimatedValue = ""
    @State private var propertyAddress = ""
    
    // Industrial-specific fields
    @State private var businessType = BusinessType.distribution
    @State private var requiredSquareFootage = ""
    @State private var currentFacilitySize = ""
    @State private var expansionTimeline = ExpansionTimeline.ninetyDays
    @State private var temperatureRequirements = TemperatureRequirements.ambient
    @State private var annualThroughput = ""
    @State private var fleetSize = ""
    @State private var shift24Hour = false
    @State private var targetMoveDate: Date?
    @State private var showingDatePicker = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var fieldErrors: Set<String> = []
    @State private var showAdvanced = false
    
    var isEditing: Bool {
        lead != nil
    }
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && 
        !requiredSquareFootage.isEmpty && Int(requiredSquareFootage) != nil
    }
    
    var hasAdvancedData: Bool {
        (!currentFacilitySize.isEmpty) || 
        (!annualThroughput.isEmpty) || 
        (!fleetSize.isEmpty) ||
        shift24Hour || 
        (targetMoveDate != nil) || 
        (!estimatedValue.isEmpty) || 
        (!propertyAddress.isEmpty) || 
        (!notes.isEmpty) || 
        (status != .new) || 
        (source != .website) ||
        (temperatureRequirements != .ambient)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Contact Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("First Name *", text: $firstName)
                                .textFieldStyle(.roundedBorder)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(fieldErrors.contains("firstName") ? Color.red : Color.clear, lineWidth: 1)
                                )
                                .onChange(of: firstName) { _, _ in
                                    fieldErrors.remove("firstName")
                                }
                            
                            TextField("Last Name *", text: $lastName)
                                .textFieldStyle(.roundedBorder)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(fieldErrors.contains("lastName") ? Color.red : Color.clear, lineWidth: 1)
                                )
                                .onChange(of: lastName) { _, _ in
                                    fieldErrors.remove("lastName")
                                }
                        }
                        
                        TextField("Email Address *", text: $email)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(fieldErrors.contains("email") ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .onChange(of: email) { _, _ in
                                fieldErrors.remove("email")
                            }
                        
                        TextField("Phone Number *", text: $phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(fieldErrors.contains("phone") ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .onChange(of: phone) { _, _ in
                                fieldErrors.remove("phone")
                            }
                    }
                    
                    Text("* Required fields")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                // Advanced Toggle - Separate Section to Avoid Touch Conflicts
                Section {
                    HStack {
                        Text("Business Requirements")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Button(showAdvanced ? "✓ Basic" : "Advanced") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAdvanced.toggle()
                                print("DEBUG: showAdvanced is now \(showAdvanced)")
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(showAdvanced ? 0.2 : 0.1))
                        .clipShape(Capsule())
                        .overlay(alignment: .topTrailing) {
                            if hasAdvancedData {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 6, height: 6)
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Basic Information") {
                    Picker("Business Type", selection: $businessType) {
                        ForEach(BusinessType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        TextField("Required Square Footage", text: $requiredSquareFootage)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(fieldErrors.contains("requiredSF") ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .onChange(of: requiredSquareFootage) { _, _ in
                                fieldErrors.remove("requiredSF")
                            }
                        
                        Text("SF")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    if requiredSquareFootage.isEmpty {
                        Text("Required")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    Picker("Expansion Timeline", selection: $expansionTimeline) {
                        ForEach(ExpansionTimeline.allCases, id: \.self) { timeline in
                            Text(timeline.rawValue).tag(timeline)
                        }
                    }
                }
                
                // Advanced Fields - Only show when toggled
                if showAdvanced {
                    Section("Operational Details") {
                        Text("DEBUG: Advanced mode is ON")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.vertical, 4)
                        Picker("Temperature Requirements", selection: $temperatureRequirements) {
                            ForEach(TemperatureRequirements.allCases, id: \.self) { temp in
                                Text(temp.rawValue).tag(temp)
                            }
                        }
                        
                        TextField("Current Facility Size", text: $currentFacilitySize)
                            .keyboardType(.numberPad)
                            .placeholder(when: currentFacilitySize.isEmpty) {
                                Text("Current SF (optional)")
                            }
                        
                        TextField("Annual Throughput", text: $annualThroughput)
                            .placeholder(when: annualThroughput.isEmpty) {
                                Text("e.g., 50M lbs/year")
                            }
                        
                        TextField("Fleet Size", text: $fleetSize)
                            .keyboardType(.numberPad)
                            .placeholder(when: fleetSize.isEmpty) {
                                Text("Number of trucks/trailers")
                            }
                        
                        Toggle("24/7 Operations", isOn: $shift24Hour)
                    }
                    
                    Section("Timeline & Financial") {
                        DatePicker("Target Move Date", selection: Binding(
                            get: { targetMoveDate ?? Date().addingTimeInterval(86400 * 90) },
                            set: { targetMoveDate = $0 }
                        ), displayedComponents: .date)
                        
                        TextField("Estimated Deal Value", text: $estimatedValue)
                            .keyboardType(.decimalPad)
                            .placeholder(when: estimatedValue.isEmpty) {
                                Text("Annual lease value")
                            }
                    }
                    
                    Section("Lead Management") {
                        Picker("Status", selection: $status) {
                            ForEach(LeadStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        
                        Picker("Source", selection: $source) {
                            ForEach(LeadSource.allCases, id: \.self) { source in
                                Text(source.rawValue).tag(source)
                            }
                        }
                        
                        TextField("Current Property Address", text: $propertyAddress)
                            .placeholder(when: propertyAddress.isEmpty) {
                                Text("Current location (optional)")
                            }
                    }
                    
                    Section("Business Notes") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Notes", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .placeholder(when: notes.isEmpty) {
                                    Text("Unique requirements, baseline needs, special considerations...")
                                }
                            
                            // Business-specific note suggestions
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(businessNoteSuggestions, id: \.self) { suggestion in
                                        Button(suggestion) {
                                            if notes.isEmpty {
                                                notes = suggestion
                                            } else {
                                                notes += "\n• \(suggestion)"
                                            }
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.secondary.opacity(0.1))
                                        .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            
                            Text("Tip: Document unique operational baselines for this business type")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Prospect" : "New Prospect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLead()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
        .alert("Validation Error", isPresented: $showingValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .onAppear {
            if let lead = lead {
                loadLeadData(lead)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadLeadData(_ lead: Lead) {
        firstName = lead.firstName
        lastName = lead.lastName
        email = lead.email
        phone = lead.phone
        status = lead.status
        source = lead.source
        notes = lead.notes
        businessType = lead.businessType
        requiredSquareFootage = String(lead.requiredSquareFootage)
        currentFacilitySize = lead.currentFacilitySize.map { String($0) } ?? ""
        expansionTimeline = lead.expansionTimeline
        temperatureRequirements = lead.temperatureRequirements
        annualThroughput = lead.annualThroughput ?? ""
        fleetSize = lead.fleetSize.map { String($0) } ?? ""
        shift24Hour = lead.shift24Hour
        targetMoveDate = lead.targetMoveDate
        estimatedValue = lead.estimatedValue.map { String($0) } ?? ""
        propertyAddress = lead.propertyAddress ?? ""
    }
    
    private func saveLead() {
        // Validate required fields
        fieldErrors.removeAll()
        
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRequiredSF = requiredSquareFootage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFirstName.isEmpty else {
            showValidationAlert(message: "First name is required")
            fieldErrors.insert("firstName")
            return
        }
        
        guard !trimmedLastName.isEmpty else {
            showValidationAlert(message: "Last name is required")
            fieldErrors.insert("lastName")
            return
        }
        
        guard !trimmedEmail.isEmpty else {
            showValidationAlert(message: "Email address is required")
            fieldErrors.insert("email")
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            showValidationAlert(message: "Please enter a valid email address")
            fieldErrors.insert("email")
            return
        }
        
        guard !trimmedPhone.isEmpty else {
            showValidationAlert(message: "Phone number is required")
            fieldErrors.insert("phone")
            return
        }
        
        guard !trimmedRequiredSF.isEmpty, let requiredSF = Int(trimmedRequiredSF) else {
            showValidationAlert(message: "Required square footage must be a valid number")
            fieldErrors.insert("requiredSF")
            return
        }
        
        if let existingLead = lead {
            // Update existing lead
            var updatedLead = existingLead
            updatedLead.firstName = trimmedFirstName
            updatedLead.lastName = trimmedLastName
            updatedLead.email = trimmedEmail
            updatedLead.phone = trimmedPhone
            updatedLead.status = status
            updatedLead.source = source
            updatedLead.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedLead.businessType = businessType
            updatedLead.requiredSquareFootage = requiredSF
            updatedLead.currentFacilitySize = Int(currentFacilitySize.trimmingCharacters(in: .whitespacesAndNewlines))
            updatedLead.expansionTimeline = expansionTimeline
            updatedLead.temperatureRequirements = temperatureRequirements
            updatedLead.annualThroughput = annualThroughput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : annualThroughput.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedLead.fleetSize = Int(fleetSize.trimmingCharacters(in: .whitespacesAndNewlines))
            updatedLead.shift24Hour = shift24Hour
            updatedLead.targetMoveDate = targetMoveDate
            updatedLead.estimatedValue = Double(estimatedValue.trimmingCharacters(in: .whitespacesAndNewlines))
            updatedLead.propertyAddress = propertyAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : propertyAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            
            dataManager.updateLead(updatedLead)
        } else {
            // Create new lead
            var newLead = Lead(
                firstName: trimmedFirstName,
                lastName: trimmedLastName,
                email: trimmedEmail,
                phone: trimmedPhone,
                source: source,
                businessType: businessType,
                requiredSquareFootage: requiredSF
            )
            
            // Set additional properties
            newLead.status = status
            newLead.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            newLead.currentFacilitySize = Int(currentFacilitySize.trimmingCharacters(in: .whitespacesAndNewlines))
            newLead.expansionTimeline = expansionTimeline
            newLead.temperatureRequirements = temperatureRequirements
            newLead.annualThroughput = annualThroughput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : annualThroughput.trimmingCharacters(in: .whitespacesAndNewlines)
            newLead.fleetSize = Int(fleetSize.trimmingCharacters(in: .whitespacesAndNewlines))
            newLead.shift24Hour = shift24Hour
            newLead.targetMoveDate = targetMoveDate
            newLead.estimatedValue = Double(estimatedValue.trimmingCharacters(in: .whitespacesAndNewlines))
            newLead.propertyAddress = propertyAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : propertyAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            
            dataManager.addLead(newLead)
        }
        
        // Success haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        dismiss()
    }
    
    private func showValidationAlert(message: String) {
        validationMessage = message
        showingValidationAlert = true
        
        // Error haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Business-Specific Note Suggestions
    private var businessNoteSuggestions: [String] {
        switch businessType {
        case .manufacturing:
            return ["Heavy machinery requirements", "24/7 operations", "Specialized power needs", "Environmental compliance"]
        case .distribution:
            return ["High dock count needed", "Cross-dock capabilities", "Fleet parking requirements", "Rapid throughput"]
        case .ecommerce:
            return ["Seasonal scaling needs", "Automation-ready", "Returns processing area", "Peak capacity planning"]
        case .coldStorage:
            return ["Temperature zones required", "Energy efficiency critical", "Specialized flooring", "Backup power essential"]
        case .automotive:
            return ["Heavy floor loading", "Paint booth requirements", "Parts storage needs", "Service bay access"]
        case .foodBeverage:
            return ["FDA compliance required", "Sanitary design", "Temperature control", "Wash-down capabilities"]
        case .retail:
            return ["Customer access needed", "Display area requirements", "Seasonal inventory", "Returns processing"]
        case .other:
            return ["Unique requirements", "Special considerations", "Custom needs", "Industry-specific"]
        }
    }
}

#Preview {
    AddEditLeadView(lead: nil)
        .environmentObject(DataManager.shared)
}