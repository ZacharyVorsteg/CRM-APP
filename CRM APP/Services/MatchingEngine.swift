//
//  MatchingEngine.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation

struct PropertyMatch {
    let property: Property
    let score: Double
    let reasons: [String]
}

class MatchingEngine {
    static func findMatches(for lead: Lead, in properties: [Property]) -> [PropertyMatch] {
        let availableProperties = properties.filter { $0.status == .available }
        
        var matches: [PropertyMatch] = []
        
        for property in availableProperties {
            var score: Double = 0
            var reasons: [String] = []
            
            // Size matching (most important factor)
            let sizeRatio = Double(property.squareFootage) / Double(lead.requiredSquareFootage)
            if sizeRatio >= 0.8 && sizeRatio <= 1.5 {
                score += 40
                reasons.append("Size match (\(property.formattedSquareFootage))")
            } else if sizeRatio >= 0.6 && sizeRatio <= 2.0 {
                score += 20
                reasons.append("Size acceptable")
            }
            
            // Temperature requirements
            if lead.temperatureRequirements == .ambient && property.sprinklerSystem != .none {
                score += 15
                reasons.append("Standard warehouse")
            } else if lead.temperatureRequirements == .cooler || lead.temperatureRequirements == .freezer {
                // Cold storage properties would need special identification
                score += 10
            }
            
            // Business type compatibility
            switch lead.businessType {
            case .thirdPartyLogistics, .distribution:
                if property.loadingDocks >= 4 {
                    score += 15
                    reasons.append("Good dock count (\(property.loadingDocks) docks)")
                }
                if property.clearHeight >= 28 {
                    score += 10
                    reasons.append("High clear height")
                }
            case .manufacturing:
                if property.clearHeight >= 24 {
                    score += 10
                    reasons.append("Manufacturing height")
                }
                if property.powerCapacity.contains("480V") || property.powerCapacity.contains("high") {
                    score += 15
                    reasons.append("Industrial power")
                }
            case .ecommerce:
                if property.loadingDocks >= 2 {
                    score += 10
                    reasons.append("E-commerce ready")
                }
            default:
                break
            }
            
            // 24-hour operations compatibility
            if lead.shift24Hour && property.zoning == .heavyIndustrial {
                score += 10
                reasons.append("24/7 operations allowed")
            }
            
            // Timeline urgency
            if lead.expansionTimeline == .immediate || lead.expansionTimeline == .thirtyDays {
                let daysUntilAvailable = Calendar.current.dateComponents([.day], from: Date(), to: property.availableDate).day ?? 0
                if daysUntilAvailable <= 30 {
                    score += 15
                    reasons.append("Available soon")
                }
            }
            
            // Only include properties with reasonable scores
            if score >= 20 {
                matches.append(PropertyMatch(property: property, score: score, reasons: reasons))
            }
        }
        
        // Sort by score descending
        return matches.sorted { $0.score > $1.score }
    }
    
    static func getMatchSummary(for lead: Lead, in properties: [Property]) -> String {
        let matches = findMatches(for: lead, in: properties)
        
        if matches.isEmpty {
            return "No matches found"
        } else if matches.count == 1 {
            return "1 potential match"
        } else {
            return "\(matches.count) potential matches"
        }
    }
}
