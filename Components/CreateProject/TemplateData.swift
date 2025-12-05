//
//  TemplateData.swift
//  Tracura
//
//  Created for template data storage
//  Edit this file to add, modify, or remove templates
//

import Foundation

// MARK: - Template Display Model
struct TemplateDisplayItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let phasesCount: Int
    let departmentsCount: Int
    
    // Reference to the full ProjectTemplate if needed
    var projectTemplate: ProjectTemplate? {
        return TemplateDataStore.getProjectTemplate(for: id)
    }
}

// MARK: - Template Data Store
struct TemplateDataStore {
    
    // MARK: - Template Data Dictionary
    // Edit this dictionary to add, modify, or remove templates
    // Each template is stored as a dictionary with the following keys:
    // - "id": Unique identifier (String)
    // - "icon": SF Symbol name (String)
    // - "title": Template name (String)
    // - "description": Template description (String)
    // - "phasesCount": Number of phases (Int)
    // - "departmentsCount": Total number of departments (Int)
    static let templateData: [String: [String: Any]] = [
        "residential_building": [
            "id": "residential_building",
            "icon": "house.fill",
            "title": "Residential Building",
            "description": "Standard template for residential building construction projects",
            "phasesCount": 2,
            "departmentsCount": 5
        ],
        "commercial_office": [
            "id": "commercial_office",
            "icon": "building.2.fill",
            "title": "Commercial Office",
            "description": "Template for commercial office space construction and fit-out",
            "phasesCount": 2,
            "departmentsCount": 6
        ],
        "road_infrastructure": [
            "id": "road_infrastructure",
            "icon": "road.lanes",
            "title": "Road Infrastructure",
            "description": "Template for road construction and infrastructure projects",
            "phasesCount": 2,
            "departmentsCount": 4
        ],
        "renovation": [
            "id": "renovation",
            "icon": "hammer.fill",
            "title": "Renovation",
            "description": "Template for building renovation and remodeling projects",
            "phasesCount": 2,
            "departmentsCount": 4
        ],
        "Checking": [
            "id": "Checking",
            "icon": "hammer.fill",
            "title": "Checking",
            "description": "Template for building renovation and remodeling projects",
            "phasesCount": 2,
            "departmentsCount": 4
        ]
    ]
    
    // MARK: - Get All Templates
    static func getAllTemplates() -> [TemplateDisplayItem] {
        return templateData.compactMap { (key, value) in
            guard let id = value["id"] as? String,
                  let icon = value["icon"] as? String,
                  let title = value["title"] as? String,
                  let description = value["description"] as? String,
                  let phasesCount = value["phasesCount"] as? Int,
                  let departmentsCount = value["departmentsCount"] as? Int else {
                return nil
            }
            
            return TemplateDisplayItem(
                id: id,
                icon: icon,
                title: title,
                description: description,
                phasesCount: phasesCount,
                departmentsCount: departmentsCount
            )
        }
        .sorted { $0.title < $1.title }
    }
    
    // MARK: - Get Project Template by ID
    static func getProjectTemplate(for id: String) -> ProjectTemplate? {
        return ProjectTemplate.predefinedTemplates.first { $0.id == id }
    }
    
    // MARK: - Search Templates
    static func searchTemplates(query: String) -> [TemplateDisplayItem] {
        let allTemplates = getAllTemplates()
        if query.isEmpty {
            return allTemplates
        }
        
        return allTemplates.filter { template in
            template.title.localizedCaseInsensitiveContains(query) ||
            template.description.localizedCaseInsensitiveContains(query)
        }
    }
}
