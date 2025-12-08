//
//  ProjectTemplate.swift
//  Tracura
//
//  Created for project templates
//

import Foundation

// MARK: - Project Template Model
struct ProjectTemplate: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let location: String
    let currency: String
    let plannedDate: Date
    let phases: [TemplatePhase]
    let allowTemplateOverrides: Bool
    
    struct TemplatePhase: Codable {
        let phaseName: String
        let startDate: Date
        let endDate: Date
        let departments: [TemplateDepartment]
    }
    
    struct TemplateDepartment: Codable {
        let name: String
        let contractorMode: ContractorMode
        let lineItems: [TemplateLineItem]
    }
    
    struct TemplateLineItem: Codable {
        let itemType: String
        let item: String
        let spec: String
        let quantity: String
        let uom: String // Unit of Measurement
        let unitPrice: String
        
        init(itemType: String, item: String, spec: String, quantity: String, uom: String = "", unitPrice: String) {
            self.itemType = itemType
            self.item = item
            self.spec = spec
            self.quantity = quantity
            self.uom = uom
            self.unitPrice = unitPrice
        }
    }
}

// MARK: - Business Type Template Filtering
extension ProjectTemplate {
    /// Get templates filtered by business type
    /// - Parameter businessType: The business type ("Construction", "Interior Design", "Media")
    /// - Returns: Array of ProjectTemplate filtered by business type
    static func getTemplatesByBusinessType(_ businessType: String?) -> [ProjectTemplate] {
        // Use TemplateDataStore to get templates by business type
        let displayItems = TemplateDataStore.getTemplatesByBusinessType(businessType)
        
        // Convert TemplateDisplayItem to ProjectTemplate
        return displayItems.compactMap { displayItem in
            TemplateDataStore.getProjectTemplate(for: displayItem.id)
        }
    }
    
    /// Switch function to get templates based on business type
    /// - Parameter businessType: The business type from customer document
    /// - Returns: Array of ProjectTemplate for the specific business type
    static func templatesForBusinessType(_ businessType: String?) -> [ProjectTemplate] {
        switch businessType?.lowercased() {
        case "construction":
            // Return construction templates
            return getTemplatesByBusinessType("Construction")
            
        case "interior design":
            // Return interior design templates
            return getTemplatesByBusinessType("Interior Design")
            
        case "media":
            // Return media templates
            return getTemplatesByBusinessType("Media")
            
        default:
            // If businessType is nil or doesn't match, return all templates from TemplateDataStore
            return getTemplatesByBusinessType(nil)
        }
    }
}
