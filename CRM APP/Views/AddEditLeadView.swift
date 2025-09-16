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
    
    var isEditing: Bool {
        lead != nil
    }
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && 
        !requiredSquareFootage.isEmpty && Int(requiredSquareFootage) != nil
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
                                .onChange(of: firstName) { _ in
                                    fieldErrors.remove("firstName")
                                }
                            
                            TextField("Last Name *", text: $lastName)
                                .textFieldStyle(.roundedBorder)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(fieldErrors.contains("lastName") ? Color.red : Color.clear, lineWidth: 1)
                                )
                                .onChange(of: lastName) { _ in
                                    fieldErrors.remove("lastName")
                                }
                        }
                        
                        TextField("Email Address *", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(fieldErrors.contains("email") ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .onChange(of: email) { _ in
                                fieldErrors.remove("email")
                            }
                        
                        TextField("Phone Number *", text: $phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(.roundedBorder)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(fieldErrors.contains("phone") ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .onChange(of: phone) { _ in
                                fieldErrors.remove("phone")
                            }
                    }
                    
                    Text("* Required fields")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Space Requirements") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Picker("Business Type", selection: $businessType) {
                                ForEach(BusinessType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Picker("Timeline", selection: $expansionTimeline) {
                                ForEach(ExpansionTimeline.allCases, id: \.self) { timeline in
                                    Text(timeline.rawValue).tag(timeline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        HStack {
                            TextField("Required Square Feet *", text: $requiredSquareFootage)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(fieldErrors.contains("requiredSF") ? Color.red : Color.clear, lineWidth: 1)
                                )
                                .onChange(of: requiredSquareFootage) { _ in
                                    fieldErrors.remove("requiredSF")
                                }
                            
                            Picker("Temperature", selection: $temperatureRequirements) {
                                ForEach(TemperatureRequirements.allCases, id: \.self) { temp in
                                    Text(temp.rawValue).tag(temp)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        HStack {
                            Toggle("24/7 Operations", isOn: $shift24Hour)
                            
                            Spacer()
                        }
                        
                        // Optional fields section
                        DisclosureGroup("Additional Details (Optional)") {
                            VStack(spacing: 12) {
                                TextField("Current Facility Size", text: $currentFacilitySize)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Fleet Size", text: $fleetSize)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Annual Throughput", text: $annualThroughput)
                                    .textFieldStyle(.roundedBorder)
                                    .placeholder(when: annualThroughput.isEmpty) {
                                        Text("e.g., 50M lbs/year")
                                    }
                            }
                        }
                    }
                }
                
                Section("Lead Details") {
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
                    
                    TextField("Estimated Annual Lease Value", text: $estimatedValue)
                        .keyboardType(.decimalPad)
                    
                    TextField("Current Property Address (optional)", text: $propertyAddress)
                    
                    HStack {
                        Text("Target Move Date")
                        Spacer()
                        if let date = targetMoveDate {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.blue)
                        } else {
                            Text("Not Set")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onTapGesture {
                        showingDatePicker = true
                    }
                }
                
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Lead" : "New Lead")
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
                    .foregroundColor(isFormValid ? .blue : .secondary)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $targetMoveDate)
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
    
    private func loadLeadData(_ lead: Lead) {
        firstName = lead.firstName
        lastName = lead.lastName
        email = lead.email
        phone = lead.phone
        status = lead.status
        source = lead.source
        notes = lead.notes
        estimatedValue = lead.estimatedValue?.formatted() ?? ""
        propertyAddress = lead.propertyAddress ?? ""
        
        // Industrial-specific fields
        businessType = lead.businessType
        requiredSquareFootage = String(lead.requiredSquareFootage)
        currentFacilitySize = lead.currentFacilitySize?.description ?? ""
        expansionTimeline = lead.expansionTimeline
        temperatureRequirements = lead.temperatureRequirements
        annualThroughput = lead.annualThroughput ?? ""
        fleetSize = lead.fleetSize?.description ?? ""
        shift24Hour = lead.shift24Hour
        targetMoveDate = lead.targetMoveDate
    }
    
    private func saveLead() {
        // Validation
        guard !firstName.isEmpty else {
            showValidationAlert(message: "First name is required")
            return
        }
        
        guard !lastName.isEmpty else {
            showValidationAlert(message: "Last name is required")
            return
        }
        
        guard !email.isEmpty else {
            showValidationAlert(message: "Email address is required")
            return
        }
        
        guard isValidEmail(email) else {
            showValidationAlert(message: "Please enter a valid email address")
            return
        }
        
        guard !phone.isEmpty else {
            showValidationAlert(message: "Phone number is required")
            return
        }
        
        guard let requiredSF = Int(requiredSquareFootage), requiredSF > 0 else {
            showValidationAlert(message: "Required square footage must be a valid number greater than 0")
            return
        }
        
        // Auto-generate email if placeholder
        let finalEmail = email.contains("@company.com") ? 
            "\(firstName.lowercased()).\(lastName.lowercased())@\(businessType.rawValue.lowercased().replacingOccurrences(of: " ", with: "")).com" : email
        
        if let existingLead = lead {
            // Update existing lead
            var updatedLead = existingLead
            updatedLead.firstName = firstName
            updatedLead.lastName = lastName
            updatedLead.email = finalEmail
            updatedLead.phone = phone
            updatedLead.status = status
            updatedLead.source = source
            updatedLead.notes = notes
            updatedLead.estimatedValue = Double(estimatedValue)
            updatedLead.propertyAddress = propertyAddress.isEmpty ? nil : propertyAddress
            
            // Industrial-specific fields
            updatedLead.businessType = businessType
            updatedLead.requiredSquareFootage = requiredSF
            updatedLead.currentFacilitySize = Int(currentFacilitySize)
            updatedLead.expansionTimeline = expansionTimeline
            updatedLead.temperatureRequirements = temperatureRequirements
            updatedLead.annualThroughput = annualThroughput.isEmpty ? nil : annualThroughput
            updatedLead.fleetSize = Int(fleetSize)
            updatedLead.shift24Hour = shift24Hour
            updatedLead.targetMoveDate = targetMoveDate
            
            dataManager.updateLead(updatedLead)
        } else {
            // Create new lead
            var newLead = Lead(
                firstName: firstName,
                lastName: lastName,
                email: finalEmail,
                phone: phone,
                source: source,
                businessType: businessType,
                requiredSquareFootage: requiredSF
            )
            newLead.status = status
            newLead.notes = notes
            newLead.estimatedValue = Double(estimatedValue)
            newLead.propertyAddress = propertyAddress.isEmpty ? nil : propertyAddress
            newLead.currentFacilitySize = Int(currentFacilitySize)
            newLead.expansionTimeline = expansionTimeline
            newLead.temperatureRequirements = temperatureRequirements
            newLead.annualThroughput = annualThroughput.isEmpty ? nil : annualThroughput
            newLead.fleetSize = Int(fleetSize)
            newLead.shift24Hour = shift24Hour
            newLead.targetMoveDate = targetMoveDate
            
            dataManager.addLead(newLead)
        }
        
        // Success feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showValidationAlert(message: String) {
        validationMessage = message
        showingValidationAlert = true
        
        // Add visual feedback to problematic fields
        if message.contains("First name") {
            fieldErrors.insert("firstName")
        } else if message.contains("Last name") {
            fieldErrors.insert("lastName")
        } else if message.contains("Email") {
            fieldErrors.insert("email")
        } else if message.contains("Phone") {
            fieldErrors.insert("phone")
        } else if message.contains("square footage") {
            fieldErrors.insert("requiredSF")
        }
        
        // Haptic feedback for error
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

#Preview {
    AddEditLeadView(lead: nil)
        .environmentObject(DataManager.shared)
}
