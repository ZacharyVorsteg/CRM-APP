//
//  Deal.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation

enum DealStage: String, CaseIterable, Codable {
    case initialInquiry = "Initial Inquiry"
    case siteTour = "Site Tour"
    case loiSubmitted = "LOI Submitted"
    case loiNegotiation = "LOI Negotiation"
    case leaseDraft = "Lease Draft"
    case dueDiligence = "Due Diligence"
    case leaseExecution = "Lease Execution"
    case pendingOccupancy = "Pending Occupancy"
    case occupied = "Occupied"
    case lost = "Lost"
}

enum LeaseType: String, CaseIterable, Codable {
    case tripleNet = "NNN"
    case modifiedGross = "Modified Gross"
    case fullService = "Full Service"
    case percentage = "Percentage"
}

struct Deal: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var leadId: UUID
    var propertyId: UUID?
    var stage: DealStage
    var value: Double
    var probability: Int // 0-100
    var expectedCloseDate: Date?
    var actualCloseDate: Date?
    var notes: String
    var dateCreated: Date
    var lastUpdated: Date
    
    // Industrial leasing specific fields
    var leaseType: LeaseType
    var termLength: Int // in months
    var baseRent: Decimal
    var annualEscalation: Double // percentage
    var tiAllowance: Decimal?
    var freeRentMonths: Int
    var optionToExtend: String?
    var commissionStructure: String
    var totalAnnualValue: Decimal
    
    var monthlyRent: Decimal {
        return totalAnnualValue / 12
    }
    
    var formattedTermLength: String {
        let years = termLength / 12
        let months = termLength % 12
        
        if years == 0 {
            return "\(months) months"
        } else if months == 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else {
            return "\(years) year\(years == 1 ? "" : "s"), \(months) months"
        }
    }
    
    init(title: String, leadId: UUID, propertyId: UUID?, totalAnnualValue: Decimal) {
        self.title = title
        self.leadId = leadId
        self.propertyId = propertyId
        self.stage = .initialInquiry
        self.value = Double(truncating: totalAnnualValue as NSNumber)
        self.probability = 25
        self.expectedCloseDate = nil
        self.actualCloseDate = nil
        self.notes = ""
        self.dateCreated = Date()
        self.lastUpdated = Date()
        
        // Industrial leasing defaults
        self.leaseType = .tripleNet
        self.termLength = 60 // 5 years default
        self.baseRent = 0
        self.annualEscalation = 3.0
        self.tiAllowance = nil
        self.freeRentMonths = 0
        self.optionToExtend = nil
        self.commissionStructure = "TBD"
        self.totalAnnualValue = totalAnnualValue
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Deal, rhs: Deal) -> Bool {
        lhs.id == rhs.id
    }
}
