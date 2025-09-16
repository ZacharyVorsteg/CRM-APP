//
//  Property.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation

enum ZoningType: String, CaseIterable, Codable {
    case heavyIndustrial = "Heavy Industrial"
    case lightIndustrial = "Light Industrial"
    case flex = "Flex"
    case distribution = "Distribution"
    case manufacturing = "Manufacturing"
}

enum SprinklerSystem: String, CaseIterable, Codable {
    case esfr = "ESFR"
    case wet = "Wet"
    case dry = "Dry"
    case none = "None"
}

enum PropertyStatus: String, CaseIterable, Codable {
    case available = "Available"
    case leased = "Leased"
    case underLOI = "Under LOI"
    case offMarket = "Off Market"
}

struct Property: Identifiable, Codable, Hashable {
    let id = UUID()
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var status: PropertyStatus
    var dateAdded: Date
    var description: String
    
    // Industrial warehouse specific fields
    var squareFootage: Int
    var clearHeight: Double
    var loadingDocks: Int
    var powerCapacity: String
    var zoning: ZoningType
    var sprinklerSystem: SprinklerSystem
    var columnSpacing: String
    var truckCourtDepth: Int
    var railAccess: Bool
    var craneCapacity: String?
    var officeSquareFootage: Int
    var yardSize: Int
    var ceilingType: String
    var yearBuilt: Int?
    var askingRate: Decimal
    var availableDate: Date
    
    var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }
    
    var formattedSquareFootage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return "\(formatter.string(from: NSNumber(value: squareFootage)) ?? "0") SF"
    }
    
    var formattedClearHeight: String {
        return "\(Int(clearHeight))' clear"
    }
    
    var totalAnnualRent: Decimal {
        return Decimal(squareFootage) * askingRate
    }
    
    var officePercentage: Double {
        guard squareFootage > 0 else { return 0 }
        return Double(officeSquareFootage) / Double(squareFootage) * 100
    }
    
    var daysOnMarket: Int {
        Calendar.current.dateComponents([.day], from: dateAdded, to: Date()).day ?? 0
    }
    
    init(address: String, city: String, state: String, zipCode: String, squareFootage: Int, clearHeight: Double, askingRate: Decimal) {
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.squareFootage = squareFootage
        self.clearHeight = clearHeight
        self.askingRate = askingRate
        self.status = .available
        self.loadingDocks = 0
        self.powerCapacity = "TBD"
        self.zoning = .lightIndustrial
        self.sprinklerSystem = .wet
        self.columnSpacing = "TBD"
        self.truckCourtDepth = 130
        self.railAccess = false
        self.craneCapacity = nil
        self.officeSquareFootage = 0
        self.yardSize = 0
        self.ceilingType = "Concrete Tilt-Up"
        self.yearBuilt = nil
        self.availableDate = Date()
        self.description = ""
        self.dateAdded = Date()
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Property, rhs: Property) -> Bool {
        lhs.id == rhs.id
    }
}
