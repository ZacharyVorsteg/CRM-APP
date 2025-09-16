//
//  WorkflowEngine.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation
import SwiftUI

struct NextAction {
    let title: String
    let icon: String
    let priority: Priority
    let action: () -> Void
    
    enum Priority {
        case high, medium, low
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }
}

class WorkflowEngine {
    static func getNextActions(for lead: Lead, dataManager: DataManager) -> [NextAction] {
        var actions: [NextAction] = []
        
        // Determine next logical steps based on lead status and timeline
        switch lead.status {
        case .new:
            actions.append(NextAction(
                title: "Make Initial Contact",
                icon: "phone.fill",
                priority: lead.expansionTimeline == .immediate ? .high : .medium,
                action: {}
            ))
            
        case .contacted:
            if lead.lastContactDate == nil || daysSinceLastContact(lead) > 3 {
                actions.append(NextAction(
                    title: "Follow Up Call",
                    icon: "phone.badge.plus",
                    priority: .high,
                    action: {}
                ))
            }
            
            actions.append(NextAction(
                title: "Send Property Options",
                icon: "building.2.badge.plus",
                priority: .medium,
                action: {}
            ))
            
        case .qualified:
            let matches = MatchingEngine.findMatches(for: lead, in: dataManager.properties)
            if !matches.isEmpty {
                actions.append(NextAction(
                    title: "Schedule Site Tour",
                    icon: "location.fill",
                    priority: .high,
                    action: {}
                ))
            }
            
            actions.append(NextAction(
                title: "Prepare LOI",
                icon: "doc.text.fill",
                priority: .medium,
                action: {}
            ))
            
        case .negotiating:
            actions.append(NextAction(
                title: "Review Terms",
                icon: "doc.plaintext.fill",
                priority: .high,
                action: {}
            ))
            
        case .closed:
            actions.append(NextAction(
                title: "Schedule Move-in",
                icon: "calendar.badge.plus",
                priority: .medium,
                action: {}
            ))
            
        case .dead:
            // No actions for dead leads
            break
        }
        
        // Timeline-based urgency
        if let moveDate = lead.targetMoveDate {
            let daysUntilMove = Calendar.current.dateComponents([.day], from: Date(), to: moveDate).day ?? 0
            if daysUntilMove <= 30 && daysUntilMove > 0 {
                actions.append(NextAction(
                    title: "Expedite Process",
                    icon: "clock.badge.exclamationmark",
                    priority: .high,
                    action: {}
                ))
            }
        }
        
        return actions.sorted { $0.priority.color == .red && $1.priority.color != .red }
    }
    
    private static func daysSinceLastContact(_ lead: Lead) -> Int {
        guard let lastContact = lead.lastContactDate else { return 999 }
        return Calendar.current.dateComponents([.day], from: lastContact, to: Date()).day ?? 0
    }
}
