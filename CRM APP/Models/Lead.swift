//
//  Lead.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation
import SwiftUI

enum LeadStatus: String, CaseIterable, Codable {
    case new = "New"
    case contacted = "Contacted"
    case qualified = "Qualified"
    case negotiating = "Negotiating"
    case closed = "Closed"
    case dead = "Dead"
}

enum LeadSource: String, CaseIterable, Codable {
    case website = "Website"
    case referral = "Referral"
    case coldCall = "Cold Call"
    case directMail = "Direct Mail"
    case socialMedia = "Social Media"
    case broker = "Broker Network"
    case other = "Other"
}

enum BusinessType: String, CaseIterable, Codable {
    case thirdPartyLogistics = "3PL"
    case manufacturing = "Manufacturing"
    case distribution = "Distribution"
    case ecommerce = "E-commerce"
    case coldStorage = "Cold Storage"
    case foodBeverage = "Food & Beverage"
    case automotive = "Automotive"
    case retail = "Retail"
    case other = "Other"
}

enum ExpansionTimeline: String, CaseIterable, Codable {
    case immediate = "Immediate"
    case thirtyDays = "30 Days"
    case sixtyDays = "60 Days"
    case ninetyDays = "90 Days"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"
}

enum TemperatureRequirements: String, CaseIterable, Codable {
    case ambient = "Ambient"
    case cooler = "Cooler (35-45°F)"
    case freezer = "Freezer (0-10°F)"
    case mixed = "Mixed Temperature"
    case controlled = "Climate Controlled"
}

enum BudgetRange: String, CaseIterable, Codable {
    case under500K = "Under $500K"
    case range500K1M = "$500K - $1M"
    case range1M2M = "$1M - $2M"
    case range2M5M = "$2M - $5M"
    case over5M = "Over $5M"
    case tbd = "To Be Determined"
    
    var midpoint: Double {
        switch self {
        case .under500K: return 250_000
        case .range500K1M: return 750_000
        case .range1M2M: return 1_500_000
        case .range2M5M: return 3_500_000
        case .over5M: return 7_500_000
        case .tbd: return 0
        }
    }
    
    var color: Color {
        switch self {
        case .under500K: return .orange
        case .range500K1M: return .blue
        case .range1M2M: return .green
        case .range2M5M: return .purple
        case .over5M: return .red
        case .tbd: return .gray
        }
    }
}

struct Lead: Identifiable, Codable, Hashable {
    let id = UUID()
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var status: LeadStatus
    var source: LeadSource
    var notes: String
    var dateCreated: Date
    var lastContactDate: Date?
    var estimatedValue: Double?
    var propertyAddress: String?
    
    // Budget and financial fields
    var budgetRange: BudgetRange
    var maxBudgetPerSF: Decimal?
    var totalAnnualBudget: Decimal?
    
    // Industrial-specific fields
    var businessType: BusinessType
    var currentFacilitySize: Int?
    var expansionTimeline: ExpansionTimeline
    var temperatureRequirements: TemperatureRequirements
    var annualThroughput: String?
    var fleetSize: Int?
    var shift24Hour: Bool
    var requiredSquareFootage: Int
    var targetMoveDate: Date?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var formattedRequiredSF: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return "\(formatter.string(from: NSNumber(value: requiredSquareFootage)) ?? "0") SF"
    }
    
    var formattedBudgetPerSF: String {
        guard let budgetPerSF = maxBudgetPerSF else { return budgetRange.rawValue }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return "\(formatter.string(from: budgetPerSF as NSNumber) ?? "$0")/SF"
    }
    
    var formattedTotalBudget: String {
        if let totalBudget = totalAnnualBudget {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 0
            let value = Double(truncating: totalBudget as NSNumber)
            
            if value >= 1_000_000 {
                return String(format: "$%.1fM", value / 1_000_000)
            } else if value >= 1_000 {
                return String(format: "$%.0fK", value / 1_000)
            } else {
                return formatter.string(from: totalBudget as NSNumber) ?? "$0"
            }
        }
        return budgetRange.rawValue
    }
    
    var estimatedAnnualValue: Double {
        if let totalBudget = totalAnnualBudget {
            return Double(truncating: totalBudget as NSNumber)
        } else if let budgetPerSF = maxBudgetPerSF {
            return Double(truncating: budgetPerSF as NSNumber) * Double(requiredSquareFootage)
        } else {
            return budgetRange.midpoint
        }
    }
    
    init(firstName: String, lastName: String, email: String, phone: String, source: LeadSource, businessType: BusinessType, requiredSquareFootage: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.status = .new
        self.source = source
        self.businessType = businessType
        self.requiredSquareFootage = requiredSquareFootage
        self.expansionTimeline = .ninetyDays
        self.temperatureRequirements = .ambient
        self.shift24Hour = false
        self.notes = ""
        self.dateCreated = Date()
        self.lastContactDate = nil
        self.estimatedValue = nil
        self.propertyAddress = nil
        self.currentFacilitySize = nil
        self.annualThroughput = nil
        self.fleetSize = nil
        self.targetMoveDate = nil
        
        // Budget defaults
        self.budgetRange = .tbd
        self.maxBudgetPerSF = nil
        self.totalAnnualBudget = nil
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Lead, rhs: Lead) -> Bool {
        lhs.id == rhs.id
    }
}
