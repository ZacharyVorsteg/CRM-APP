//
//  AddEditDealView.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import SwiftUI

struct AddEditDealView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let deal: Deal?
    
    @State private var title = ""
    @State private var selectedLeadId: UUID?
    @State private var selectedPropertyId: UUID?
    @State private var stage = DealStage.initialInquiry
    @State private var value = ""
    @State private var probability = 25
    @State private var expectedCloseDate: Date?
    @State private var notes = ""
    @State private var showingDatePicker = false
    
    var isEditing: Bool {
        deal != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Deal Information") {
                    TextField("Deal Title", text: $title)
                    
                    Picker("Lead", selection: $selectedLeadId) {
                        Text("Select Lead").tag(nil as UUID?)
                        ForEach(dataManager.leads) { lead in
                            Text(lead.fullName).tag(lead.id as UUID?)
                        }
                    }
                    
                    Picker("Property (Optional)", selection: $selectedPropertyId) {
                        Text("No Property").tag(nil as UUID?)
                        ForEach(dataManager.properties) { property in
                            Text(property.address).tag(property.id as UUID?)
                        }
                    }
                }
                
                Section("Deal Details") {
                    Picker("Stage", selection: $stage) {
                        ForEach(DealStage.allCases, id: \.self) { stage in
                            Text(stage.rawValue).tag(stage)
                        }
                    }
                    
                    TextField("Deal Value", text: $value)
                        .keyboardType(.decimalPad)
                    
                    VStack {
                        HStack {
                            Text("Probability: \(probability)%")
                            Spacer()
                        }
                        Slider(value: Binding(
                            get: { Double(probability) },
                            set: { probability = Int($0) }
                        ), in: 0...100, step: 5)
                    }
                    
                    HStack {
                        Text("Expected Close Date")
                        Spacer()
                        if let date = expectedCloseDate {
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
                    TextField("Deal Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if expectedCloseDate != nil {
                    Section {
                        Button("Clear Expected Close Date", role: .destructive) {
                            expectedCloseDate = nil
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Deal" : "New Deal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDeal()
                    }
                    .disabled(title.isEmpty || selectedLeadId == nil || value.isEmpty)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $expectedCloseDate)
            }
        }
        .onAppear {
            if let deal = deal {
                loadDealData(deal)
            }
        }
    }
    
    private func loadDealData(_ deal: Deal) {
        title = deal.title
        selectedLeadId = deal.leadId
        selectedPropertyId = deal.propertyId
        stage = deal.stage
        value = String(deal.value)
        probability = deal.probability
        expectedCloseDate = deal.expectedCloseDate
        notes = deal.notes
    }
    
    private func saveDeal() {
        guard let leadId = selectedLeadId,
              let dealValue = Double(value) else { return }
        
        let totalAnnualValue = Decimal(dealValue)
        
        if let existingDeal = deal {
            // Update existing deal
            var updatedDeal = existingDeal
            updatedDeal.title = title
            updatedDeal.leadId = leadId
            updatedDeal.propertyId = selectedPropertyId
            updatedDeal.stage = stage
            updatedDeal.value = dealValue
            updatedDeal.totalAnnualValue = totalAnnualValue
            updatedDeal.probability = probability
            updatedDeal.expectedCloseDate = expectedCloseDate
            updatedDeal.notes = notes
            
            if stage == .occupied && existingDeal.stage != .occupied {
                updatedDeal.actualCloseDate = Date()
            }
            
            dataManager.updateDeal(updatedDeal)
        } else {
            // Create new deal
            var newDeal = Deal(title: title, leadId: leadId, propertyId: selectedPropertyId, totalAnnualValue: totalAnnualValue)
            newDeal.stage = stage
            newDeal.probability = probability
            newDeal.expectedCloseDate = expectedCloseDate
            newDeal.notes = notes
            
            if stage == .occupied {
                newDeal.actualCloseDate = Date()
            }
            
            dataManager.addDeal(newDeal)
        }
        
        dismiss()
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Expected Close Date", selection: $tempDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let date = selectedDate {
                tempDate = date
            }
        }
    }
}

#Preview {
    AddEditDealView(deal: nil)
        .environmentObject(DataManager.shared)
}
