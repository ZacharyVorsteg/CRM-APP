//
//  Communication.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation

enum CommunicationType: String, CaseIterable, Codable {
    case email = "Email"
    case phone = "Phone Call"
    case text = "Text Message"
    case meeting = "Meeting"
    case note = "Note"
}

struct Communication: Identifiable, Codable, Hashable {
    let id = UUID()
    var leadId: UUID
    var type: CommunicationType
    var subject: String
    var content: String
    var date: Date
    var isOutgoing: Bool // true for outgoing, false for incoming
    
    init(leadId: UUID, type: CommunicationType, subject: String, content: String, isOutgoing: Bool = true) {
        self.leadId = leadId
        self.type = type
        self.subject = subject
        self.content = content
        self.date = Date()
        self.isOutgoing = isOutgoing
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Communication, rhs: Communication) -> Bool {
        lhs.id == rhs.id
    }
}
