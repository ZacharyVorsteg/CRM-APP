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
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Lead, rhs: Lead) -> Bool {
        lhs.id == rhs.id
    }
}
