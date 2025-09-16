//
//  DataManager.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation
import SwiftUI
import CoreData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var leads: [Lead] = []
    @Published var properties: [Property] = []
    @Published var deals: [Deal] = []
    @Published var communications: [Communication] = []
    
    private let coreDataStack = CoreDataStack.shared
    private var context: NSManagedObjectContext {
        return coreDataStack.context
    }
    
    private init() {
        loadData()
    }
    
    // MARK: - Lead Management
    func addLead(_ lead: Lead) {
        print("📝 Adding lead: \(lead.fullName)")
        
        let cdLead = CDLead(context: context)
        cdLead.updateFromLead(lead)
        
        do {
            try context.save()
            print("✅ Lead saved successfully")
            
            // Reload data on main thread
            DispatchQueue.main.async {
                self.loadLeads()
            }
        } catch {
            print("❌ Error saving lead: \(error)")
        }
    }
    
    func updateLead(_ lead: Lead) {
        let request: NSFetchRequest<CDLead> = CDLead.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", lead.id as CVarArg)
        
        if let cdLead = try? context.fetch(request).first {
            cdLead.updateFromLead(lead)
            coreDataStack.save()
            loadLeads()
        }
    }
    
    func deleteLead(_ lead: Lead) {
        let request: NSFetchRequest<CDLead> = CDLead.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", lead.id as CVarArg)
        
        if let cdLead = try? context.fetch(request).first {
            context.delete(cdLead)
            coreDataStack.save()
            loadLeads()
        }
    }
    
    func getLead(by id: UUID) -> Lead? {
        return leads.first { $0.id == id }
    }
    
    // MARK: - Property Management
    func addProperty(_ property: Property) {
        let cdProperty = CDProperty(context: context)
        cdProperty.updateFromProperty(property)
        
        coreDataStack.save()
        loadProperties()
    }
    
    func updateProperty(_ property: Property) {
        let request: NSFetchRequest<CDProperty> = CDProperty.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", property.id as CVarArg)
        
        if let cdProperty = try? context.fetch(request).first {
            cdProperty.updateFromProperty(property)
            coreDataStack.save()
            loadProperties()
        }
    }
    
    func deleteProperty(_ property: Property) {
        let request: NSFetchRequest<CDProperty> = CDProperty.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", property.id as CVarArg)
        
        if let cdProperty = try? context.fetch(request).first {
            context.delete(cdProperty)
            coreDataStack.save()
            loadProperties()
        }
    }
    
    func getProperty(by id: UUID) -> Property? {
        return properties.first { $0.id == id }
    }
    
    // MARK: - Deal Management
    func addDeal(_ deal: Deal) {
        let cdDeal = CDDeal(context: context)
        cdDeal.updateFromDeal(deal, context: context)
        
        coreDataStack.save()
        loadDeals()
    }
    
    func updateDeal(_ deal: Deal) {
        let request: NSFetchRequest<CDDeal> = CDDeal.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", deal.id as CVarArg)
        
        if let cdDeal = try? context.fetch(request).first {
            var updatedDeal = deal
            updatedDeal.lastUpdated = Date()
            cdDeal.updateFromDeal(updatedDeal, context: context)
            coreDataStack.save()
            loadDeals()
        }
    }
    
    func deleteDeal(_ deal: Deal) {
        let request: NSFetchRequest<CDDeal> = CDDeal.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", deal.id as CVarArg)
        
        if let cdDeal = try? context.fetch(request).first {
            context.delete(cdDeal)
            coreDataStack.save()
            loadDeals()
        }
    }
    
    func getDeal(by id: UUID) -> Deal? {
        return deals.first { $0.id == id }
    }
    
    func getDealsForLead(_ leadId: UUID) -> [Deal] {
        return deals.filter { $0.leadId == leadId }
    }
    
    // MARK: - Communication Management
    func addCommunication(_ communication: Communication) {
        let cdCommunication = CDCommunication(context: context)
        cdCommunication.updateFromCommunication(communication, context: context)
        
        // Update lead's last contact date
        let leadRequest: NSFetchRequest<CDLead> = CDLead.fetchRequest()
        leadRequest.predicate = NSPredicate(format: "id == %@", communication.leadId as CVarArg)
        
        if let cdLead = try? context.fetch(leadRequest).first {
            cdLead.lastContactDate = communication.date
        }
        
        coreDataStack.save()
        loadCommunications()
        loadLeads() // Reload leads to update last contact date
    }
    
    func updateCommunication(_ communication: Communication) {
        let request: NSFetchRequest<CDCommunication> = CDCommunication.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", communication.id as CVarArg)
        
        if let cdCommunication = try? context.fetch(request).first {
            cdCommunication.updateFromCommunication(communication, context: context)
            coreDataStack.save()
            loadCommunications()
        }
    }
    
    func deleteCommunication(_ communication: Communication) {
        let request: NSFetchRequest<CDCommunication> = CDCommunication.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", communication.id as CVarArg)
        
        if let cdCommunication = try? context.fetch(request).first {
            context.delete(cdCommunication)
            coreDataStack.save()
            loadCommunications()
        }
    }
    
    func getCommunicationsForLead(_ leadId: UUID) -> [Communication] {
        return communications.filter { $0.leadId == leadId }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Analytics
    func getTotalLeadValue() -> Double {
        return leads.compactMap { $0.estimatedValue }.reduce(0, +)
    }
    
    func getTotalDealValue() -> Double {
        return deals.reduce(0) { $0 + $1.value }
    }
    
    func getClosedDealsValue() -> Double {
        return deals.filter { $0.stage == .occupied }.reduce(0) { $0 + $1.value }
    }
    
    func getActiveDealsCount() -> Int {
        return deals.filter { $0.stage != .occupied && $0.stage != .lost }.count
    }
    
    // MARK: - Data Loading
    private func loadData() {
        loadLeads()
        loadProperties()
        loadDeals()
        loadCommunications()
    }
    
    private func loadLeads() {
        let request: NSFetchRequest<CDLead> = CDLead.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDLead.dateCreated, ascending: false)]
        
        do {
            let cdLeads = try context.fetch(request)
            let convertedLeads = cdLeads.map { $0.toLead() }
            
            DispatchQueue.main.async {
                self.leads = convertedLeads
                print("📊 Loaded \(convertedLeads.count) leads")
            }
        } catch {
            print("❌ Error loading leads: \(error)")
            DispatchQueue.main.async {
                self.leads = []
            }
        }
    }
    
    private func loadProperties() {
        let request: NSFetchRequest<CDProperty> = CDProperty.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDProperty.dateAdded, ascending: false)]
        
        do {
            let cdProperties = try context.fetch(request)
            self.properties = cdProperties.map { $0.toProperty() }
        } catch {
            print("Error loading properties: \(error)")
            self.properties = []
        }
    }
    
    private func loadDeals() {
        let request: NSFetchRequest<CDDeal> = CDDeal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDDeal.dateCreated, ascending: false)]
        
        do {
            let cdDeals = try context.fetch(request)
            self.deals = cdDeals.compactMap { $0.toDeal() }
            print("📊 Loaded \(self.deals.count) deals")
        } catch {
            print("❌ Error loading deals: \(error)")
            self.deals = []
        }
    }
    
    private func loadCommunications() {
        let request: NSFetchRequest<CDCommunication> = CDCommunication.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDCommunication.date, ascending: false)]
        
        do {
            let cdCommunications = try context.fetch(request)
            self.communications = cdCommunications.compactMap { $0.toCommunication() }
            print("📊 Loaded \(self.communications.count) communications")
        } catch {
            print("❌ Error loading communications: \(error)")
            self.communications = []
        }
    }
}
