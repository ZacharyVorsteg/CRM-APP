//
//  CoreDataExtensions.swift
//  CRM APP
//
//  Created by Zach Thomas on 9/16/25.
//

import Foundation
import CoreData

// MARK: - Lead Extensions
extension CDLead {
    func toLead() -> Lead {
        var lead = Lead(
            firstName: firstName ?? "",
            lastName: lastName ?? "",
            email: email ?? "",
            phone: phone ?? "",
            source: LeadSource(rawValue: source ?? "") ?? .website,
            businessType: BusinessType(rawValue: businessType ?? "") ?? .distribution,
            requiredSquareFootage: Int(requiredSquareFootage)
        )
        
        lead.status = LeadStatus(rawValue: status ?? "") ?? .new
        lead.notes = notes ?? ""
        lead.estimatedValue = estimatedValue == 0 ? nil : estimatedValue
        lead.propertyAddress = propertyAddress?.isEmpty == true ? nil : propertyAddress
        lead.dateCreated = dateCreated ?? Date()
        lead.lastContactDate = lastContactDate
        
        // Industrial-specific fields
        lead.currentFacilitySize = currentFacilitySize == 0 ? nil : Int(currentFacilitySize)
        lead.expansionTimeline = ExpansionTimeline(rawValue: expansionTimeline ?? "") ?? .ninetyDays
        lead.temperatureRequirements = TemperatureRequirements(rawValue: temperatureRequirements ?? "") ?? .ambient
        lead.annualThroughput = annualThroughput?.isEmpty == true ? nil : annualThroughput
        lead.fleetSize = fleetSize == 0 ? nil : Int(fleetSize)
        lead.shift24Hour = shift24Hour
        lead.targetMoveDate = targetMoveDate
        
        return lead
    }
    
    func updateFromLead(_ lead: Lead) {
        self.id = lead.id
        self.firstName = lead.firstName
        self.lastName = lead.lastName
        self.email = lead.email
        self.phone = lead.phone
        self.status = lead.status.rawValue
        self.source = lead.source.rawValue
        self.notes = lead.notes
        self.estimatedValue = lead.estimatedValue ?? 0
        self.propertyAddress = lead.propertyAddress
        self.dateCreated = lead.dateCreated
        self.lastContactDate = lead.lastContactDate
        
        // Industrial-specific fields
        self.businessType = lead.businessType.rawValue
        self.requiredSquareFootage = Int32(lead.requiredSquareFootage)
        self.currentFacilitySize = Int32(lead.currentFacilitySize ?? 0)
        self.expansionTimeline = lead.expansionTimeline.rawValue
        self.temperatureRequirements = lead.temperatureRequirements.rawValue
        self.annualThroughput = lead.annualThroughput
        self.fleetSize = Int16(lead.fleetSize ?? 0)
        self.shift24Hour = lead.shift24Hour
        self.targetMoveDate = lead.targetMoveDate
    }
}

// MARK: - Property Extensions
extension CDProperty {
    func toProperty() -> Property {
        var property = Property(
            address: address ?? "",
            city: city ?? "",
            state: state ?? "",
            zipCode: zipCode ?? "",
            squareFootage: Int(squareFootage),
            clearHeight: clearHeight,
            askingRate: (askingRate as Decimal?) ?? 0
        )
        
        property.status = PropertyStatus(rawValue: status ?? "") ?? .available
        property.dateAdded = dateAdded ?? Date()
        property.description = descriptionText ?? ""
        property.yearBuilt = yearBuilt == 0 ? nil : Int(yearBuilt)
        
        // Industrial-specific fields
        property.loadingDocks = Int(loadingDocks)
        property.powerCapacity = powerCapacity ?? "TBD"
        property.zoning = ZoningType(rawValue: zoning ?? "") ?? .lightIndustrial
        property.sprinklerSystem = SprinklerSystem(rawValue: sprinklerSystem ?? "") ?? .wet
        property.columnSpacing = columnSpacing ?? "TBD"
        property.truckCourtDepth = Int(truckCourtDepth)
        property.railAccess = railAccess
        property.craneCapacity = craneCapacity?.isEmpty == true ? nil : craneCapacity
        property.officeSquareFootage = Int(officeSquareFootage)
        property.yardSize = Int(yardSize)
        property.ceilingType = ceilingType ?? "Concrete Tilt-Up"
        property.availableDate = availableDate ?? Date()
        
        return property
    }
    
    func updateFromProperty(_ property: Property) {
        self.id = property.id
        self.address = property.address
        self.city = property.city
        self.state = property.state
        self.zipCode = property.zipCode
        self.status = property.status.rawValue
        self.dateAdded = property.dateAdded
        self.descriptionText = property.description
        self.yearBuilt = Int32(property.yearBuilt ?? 0)
        self.askingRate = property.askingRate as NSDecimalNumber
        
        // Industrial-specific fields
        self.squareFootage = Int32(property.squareFootage)
        self.clearHeight = property.clearHeight
        self.loadingDocks = Int16(property.loadingDocks)
        self.powerCapacity = property.powerCapacity
        self.zoning = property.zoning.rawValue
        self.sprinklerSystem = property.sprinklerSystem.rawValue
        self.columnSpacing = property.columnSpacing
        self.truckCourtDepth = Int16(property.truckCourtDepth)
        self.railAccess = property.railAccess
        self.craneCapacity = property.craneCapacity
        self.officeSquareFootage = Int32(property.officeSquareFootage)
        self.yardSize = Int32(property.yardSize)
        self.ceilingType = property.ceilingType
        self.availableDate = property.availableDate
    }
}

// MARK: - Deal Extensions
extension CDDeal {
    func toDeal() -> Deal? {
        guard let leadId = lead?.id else {
            print("⚠️ Warning: Deal found without lead relationship - skipping")
            return nil
        }
        
        var deal = Deal(
            title: title ?? "",
            leadId: leadId,
            propertyId: property?.id,
            totalAnnualValue: (totalAnnualValue as Decimal?) ?? 0
        )
        
        deal.stage = DealStage(rawValue: stage ?? "") ?? .initialInquiry
        deal.probability = Int(probability)
        deal.expectedCloseDate = expectedCloseDate
        deal.actualCloseDate = actualCloseDate
        deal.notes = notes ?? ""
        deal.dateCreated = dateCreated ?? Date()
        deal.lastUpdated = lastUpdated ?? Date()
        
        // Industrial leasing specific fields
        deal.leaseType = LeaseType(rawValue: leaseType ?? "") ?? .tripleNet
        deal.termLength = Int(termLength)
        deal.baseRent = (baseRent as Decimal?) ?? 0
        deal.annualEscalation = annualEscalation
        deal.tiAllowance = (tiAllowance as Decimal?) == 0 ? nil : (tiAllowance as Decimal?)
        deal.freeRentMonths = Int(freeRentMonths)
        deal.optionToExtend = optionToExtend?.isEmpty == true ? nil : optionToExtend
        deal.commissionStructure = commissionStructure ?? "TBD"
        
        return deal
    }
    
    func updateFromDeal(_ deal: Deal, context: NSManagedObjectContext) {
        self.id = deal.id
        self.title = deal.title
        self.stage = deal.stage.rawValue
        self.value = deal.value
        self.probability = Int32(deal.probability)
        self.expectedCloseDate = deal.expectedCloseDate
        self.actualCloseDate = deal.actualCloseDate
        self.notes = deal.notes
        self.dateCreated = deal.dateCreated
        self.lastUpdated = deal.lastUpdated
        
        // Industrial leasing specific fields
        self.leaseType = deal.leaseType.rawValue
        self.termLength = Int16(deal.termLength)
        self.baseRent = deal.baseRent as NSDecimalNumber
        self.annualEscalation = deal.annualEscalation
        self.tiAllowance = (deal.tiAllowance ?? 0) as NSDecimalNumber
        self.freeRentMonths = Int16(deal.freeRentMonths)
        self.optionToExtend = deal.optionToExtend
        self.commissionStructure = deal.commissionStructure
        self.totalAnnualValue = deal.totalAnnualValue as NSDecimalNumber
        
        // Find and set the lead relationship
        let leadRequest: NSFetchRequest<CDLead> = CDLead.fetchRequest()
        leadRequest.predicate = NSPredicate(format: "id == %@", deal.leadId as CVarArg)
        
        if let lead = try? context.fetch(leadRequest).first {
            self.lead = lead
        }
        
        // Find and set the property relationship if exists
        if let propertyId = deal.propertyId {
            let propertyRequest: NSFetchRequest<CDProperty> = CDProperty.fetchRequest()
            propertyRequest.predicate = NSPredicate(format: "id == %@", propertyId as CVarArg)
            
            if let property = try? context.fetch(propertyRequest).first {
                self.property = property
            }
        }
    }
}

// MARK: - Communication Extensions
extension CDCommunication {
    func toCommunication() -> Communication? {
        guard let leadId = lead?.id else {
            print("⚠️ Warning: Communication found without lead relationship - skipping")
            return nil
        }
        
        var communication = Communication(
            leadId: leadId,
            type: CommunicationType(rawValue: type ?? "") ?? .email,
            subject: subject ?? "",
            content: content ?? "",
            isOutgoing: isOutgoing
        )
        
        communication.date = date ?? Date()
        
        return communication
    }
    
    func updateFromCommunication(_ communication: Communication, context: NSManagedObjectContext) {
        self.id = communication.id
        self.type = communication.type.rawValue
        self.subject = communication.subject
        self.content = communication.content
        self.date = communication.date
        self.isOutgoing = communication.isOutgoing
        
        // Find and set the lead relationship
        let leadRequest: NSFetchRequest<CDLead> = CDLead.fetchRequest()
        leadRequest.predicate = NSPredicate(format: "id == %@", communication.leadId as CVarArg)
        
        if let lead = try? context.fetch(leadRequest).first {
            self.lead = lead
        }
    }
}
