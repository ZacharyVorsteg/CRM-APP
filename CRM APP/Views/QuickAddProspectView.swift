//
//  QuickAddProspectView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI
import UIKit

struct QuickAddProspectView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var businessType = BusinessType.distribution
    @State private var requiredSquareFootage = ""
    @State private var expansionTimeline = ExpansionTimeline.ninetyDays
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Quick Add Prospect")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Essential info only - add details later")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    VStack(spacing: 20) {
                        // Contact Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contact")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                TextField("First Name *", text: $firstName)
                                    .textFieldStyle(.roundedBorder)
                                    .submitLabel(.next)
                                TextField("Last Name *", text: $lastName)
                                    .textFieldStyle(.roundedBorder)
                                    .submitLabel(.next)
                            }
                            
                            TextField("Email Address *", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.next)
                            
                            TextField("Phone Number *", text: $phone)
                                .keyboardType(.phonePad)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                        }
                        
                        // Business Requirements
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Requirements")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                Picker("Business Type", selection: $businessType) {
                                    ForEach(BusinessType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 12) {
                                    TextField("Required SF *", text: $requiredSquareFootage)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)
                                        .submitLabel(.done)
                                    
                                    Picker("Timeline", selection: $expansionTimeline) {
                                        ForEach(ExpansionTimeline.allCases, id: \.self) { timeline in
                                            Text(timeline.rawValue).tag(timeline)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button("Save & Call Now") {
                            saveAndCall()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .disabled(!isFormValid)
                        
                        Button("Save Only") {
                            saveOnly()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .disabled(!isFormValid)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .dismissKeyboard()
        }
        .alert("Validation Error", isPresented: $showingValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
    }
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && 
        !requiredSquareFootage.isEmpty && Int(requiredSquareFootage) != nil
    }
    
    private func saveAndCall() {
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
        
        guard !phone.isEmpty else {
            showValidationAlert(message: "Phone number is required")
            return
        }
        
        guard let requiredSF = Int(requiredSquareFootage), requiredSF > 0 else {
            showValidationAlert(message: "Required square footage must be a valid number greater than 0")
            return
        }
        
        let lead = Lead(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            source: .coldCall,
            businessType: businessType,
            requiredSquareFootage: requiredSF
        )
        
        var newLead = lead
        newLead.expansionTimeline = expansionTimeline
        newLead.status = .contacted
        
        dataManager.addLead(newLead)
        
        // Auto-log the initial call
        let communication = Communication(
            leadId: newLead.id,
            type: .phone,
            subject: "Initial Contact",
            content: "First contact - \(businessType.rawValue) looking for \(requiredSquareFootage) SF"
        )
        dataManager.addCommunication(communication)
        
        dismiss()
        
        // Open phone app
        let cleanPhone = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        if let phoneURL = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(phoneURL)
        }
    }
    
    private func saveOnly() {
        // Same validation as saveAndCall
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !phone.isEmpty else {
            showValidationAlert(message: "Please fill in all required fields")
            return
        }
        
        guard let requiredSF = Int(requiredSquareFootage), requiredSF > 0 else {
            showValidationAlert(message: "Required square footage must be a valid number greater than 0")
            return
        }
        
        let lead = Lead(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            source: .coldCall,
            businessType: businessType,
            requiredSquareFootage: requiredSF
        )
        
        var newLead = lead
        newLead.expansionTimeline = expansionTimeline
        
        dataManager.addLead(newLead)
        
        // Success feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func showValidationAlert(message: String) {
        validationMessage = message
        showingValidationAlert = true
        
        // Haptic feedback for error
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
}

#Preview {
    QuickAddProspectView()
        .environmentObject(DataManager.shared)
}
