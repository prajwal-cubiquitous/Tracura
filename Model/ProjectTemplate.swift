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
        let unitPrice: String
    }
}

// MARK: - Predefined Templates
extension ProjectTemplate {
    static let predefinedTemplates: [ProjectTemplate] = [
        // Template 1: Residential Building Construction (AVR Construction Budgets)
        ProjectTemplate(
            id: "residential_building",
            name: "Residential Building",
            description: "Standard template for residential building construction projects with AVR construction budgets",
            icon: "house.fill",
            location: "",
            currency: "INR",
            plannedDate: Date(),
            phases: [
                TemplatePhase(
                    phaseName: "Foundation & Structure",
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .turnkey,
                            lineItems: [
                                // Raw Materials - Cement
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 53", quantity: "500", unitPrice: "380"),
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 43", quantity: "200", unitPrice: "360"),
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "PPC", quantity: "100", unitPrice: "350"),
                                
                                // Raw Materials - Steel (all sizes)
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 6 mm", quantity: "10", unitPrice: "58000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 8 mm", quantity: "15", unitPrice: "59000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 10 mm", quantity: "20", unitPrice: "60000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 12 mm", quantity: "25", unitPrice: "62000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 16 mm", quantity: "30", unitPrice: "62000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 20 mm", quantity: "15", unitPrice: "62000"),
                                
                                // Raw Materials - Sand (all types)
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "M-Sand • Zone I", quantity: "100", unitPrice: "800"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "M-Sand • Zone II", quantity: "150", unitPrice: "800"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Coarse)", quantity: "200", unitPrice: "1200"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Fine)", quantity: "100", unitPrice: "1100"),
                                
                                // Machines & Equipment
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-day hire", quantity: "15", unitPrice: "12000"),
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-hour hire", quantity: "50", unitPrice: "1500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Tractor / Trolley", spec: "Per-trip", quantity: "80", unitPrice: "800"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Tractor / Trolley", spec: "Per-day", quantity: "20", unitPrice: "2500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Concrete Mixer", spec: "Per-day hire", quantity: "20", unitPrice: "1500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Vibrator", spec: "Per-day hire", quantity: "15", unitPrice: "800"),
                                
                                // Labour (all types)
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Unskilled", quantity: "20", unitPrice: "500"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "10", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "12", unitPrice: "750"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Mason", quantity: "8", unitPrice: "900"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "15", unitPrice: "550")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Electrical",
                            contractorMode: .turnkey,
                            lineItems: [
                                // Wires & Cables (all sizes)
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "1.5 sq mm", quantity: "500", unitPrice: "75"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "2.5 sq mm", quantity: "800", unitPrice: "95"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "4 sq mm", quantity: "400", unitPrice: "145"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "6 sq mm", quantity: "200", unitPrice: "220"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "10 sq mm", quantity: "100", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "16 sq mm", quantity: "50", unitPrice: "550"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "25 sq mm", quantity: "30", unitPrice: "850"),
                                
                                // Switches & Sockets (all types)
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Single pole", quantity: "40", unitPrice: "120"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Double pole", quantity: "30", unitPrice: "150"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Triple pole", quantity: "20", unitPrice: "180"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "5A socket", quantity: "25", unitPrice: "200"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "15A socket", quantity: "15", unitPrice: "250"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Modular switches", quantity: "60", unitPrice: "180"),
                                
                                // MCB & DB (all types)
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "6A MCB", quantity: "15", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "10A MCB", quantity: "20", unitPrice: "400"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "16A MCB", quantity: "20", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "20A MCB", quantity: "15", unitPrice: "550"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "32A MCB", quantity: "10", unitPrice: "650"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "Distribution Board", quantity: "4", unitPrice: "8500"),
                                
                                // Lighting (all types)
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Bulb", quantity: "60", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Tube", quantity: "40", unitPrice: "650"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Panel", quantity: "50", unitPrice: "1200"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Strip", quantity: "30", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "CFL", quantity: "20", unitPrice: "280"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "Halogen", quantity: "15", unitPrice: "400"),
                                
                                // Conduits & Accessories (all sizes)
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "20mm PVC", quantity: "200", unitPrice: "70"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "25mm PVC", quantity: "300", unitPrice: "85"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "32mm PVC", quantity: "150", unitPrice: "120"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "40mm PVC", quantity: "100", unitPrice: "150"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Elbow", quantity: "80", unitPrice: "45"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Coupler", quantity: "60", unitPrice: "35"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Bend", quantity: "50", unitPrice: "55"),
                                
                                // Labour
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "4", unitPrice: "850"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "3", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "5", unitPrice: "550")
                            ]
                        )
                    ]
                ),
                TemplatePhase(
                    phaseName: "Finishing & Interior",
                    startDate: Calendar.current.date(byAdding: .day, value: 91, to: Date()) ?? Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 180, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .turnkey,
                            lineItems: [
                                // Raw Materials
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 43", quantity: "200", unitPrice: "360"),
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "PPC", quantity: "100", unitPrice: "350"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Fine)", quantity: "100", unitPrice: "1100"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "M-Sand • Zone II", quantity: "80", unitPrice: "800"),
                                
                                // Tiles
                                TemplateLineItem(itemType: "Tiles", item: "Floor Tiles", spec: "Vitrified", quantity: "250", unitPrice: "85"),
                                TemplateLineItem(itemType: "Tiles", item: "Wall Tiles", spec: "Ceramic", quantity: "180", unitPrice: "95"),
                                
                                // Paint
                                TemplateLineItem(itemType: "Paint", item: "Interior Paint", spec: "Premium", quantity: "120", unitPrice: "520"),
                                TemplateLineItem(itemType: "Paint", item: "Exterior Paint", spec: "Weatherproof", quantity: "80", unitPrice: "680"),
                                
                                // Machines & Equipment
                                TemplateLineItem(itemType: "Machines & eq", item: "Concrete Mixer", spec: "Per-day hire", quantity: "10", unitPrice: "1500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Vibrator", spec: "Per-day hire", quantity: "8", unitPrice: "800"),
                                
                                // Labour (all types)
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Unskilled", quantity: "10", unitPrice: "500"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "5", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "8", unitPrice: "750"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Mason", quantity: "6", unitPrice: "900"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "8", unitPrice: "550")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Plumbing",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Plumbing", item: "CPVC Pipes", spec: "1 inch", quantity: "250", unitPrice: "145"),
                                TemplateLineItem(itemType: "Plumbing", item: "Fittings", spec: "Standard", quantity: "120", unitPrice: "55"),
                                TemplateLineItem(itemType: "Plumbing", item: "Fixtures", spec: "Premium", quantity: "25", unitPrice: "2200"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "3", unitPrice: "850")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Electrical",
                            contractorMode: .turnkey,
                            lineItems: [
                                // Wires & Cables
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "1.5 sq mm", quantity: "300", unitPrice: "75"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "2.5 sq mm", quantity: "400", unitPrice: "95"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "4 sq mm", quantity: "200", unitPrice: "145"),
                                
                                // Switches & Sockets
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Single pole", quantity: "25", unitPrice: "120"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Modular switches", quantity: "40", unitPrice: "180"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "15A socket", quantity: "20", unitPrice: "250"),
                                
                                // MCB & DB
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "16A MCB", quantity: "15", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "20A MCB", quantity: "10", unitPrice: "550"),
                                
                                // Lighting (all types)
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Bulb", quantity: "80", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Tube", quantity: "25", unitPrice: "650"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Panel", quantity: "30", unitPrice: "1200"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Strip", quantity: "20", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "CFL", quantity: "15", unitPrice: "280"),
                                
                                // Conduits & Accessories
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "20mm PVC", quantity: "150", unitPrice: "70"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "25mm PVC", quantity: "200", unitPrice: "85"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Elbow", quantity: "50", unitPrice: "45"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Coupler", quantity: "40", unitPrice: "35"),
                                
                                // Labour
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "2", unitPrice: "850"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "2", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "3", unitPrice: "550")
                            ]
                        )
                    ]
                )
            ],
            allowTemplateOverrides: false
        ),
        
        // Template 2: Commercial Office Space (AVR Construction Budgets)
        ProjectTemplate(
            id: "commercial_office",
            name: "Commercial Office",
            description: "Template for commercial office space construction and fit-out with AVR construction budgets",
            icon: "building.2.fill",
            location: "",
            currency: "INR",
            plannedDate: Date(),
            phases: [
                TemplatePhase(
                    phaseName: "Shell & Core",
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 120, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .turnkey,
                            lineItems: [
                                // Raw Materials - Cement (all types)
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 53", quantity: "800", unitPrice: "380"),
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 43", quantity: "300", unitPrice: "360"),
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "PPC", quantity: "200", unitPrice: "350"),
                                
                                // Raw Materials - Steel (all sizes)
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 10 mm", quantity: "40", unitPrice: "60000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 12 mm", quantity: "50", unitPrice: "62000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 16 mm", quantity: "60", unitPrice: "62000"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 20 mm", quantity: "50", unitPrice: "62000"),
                                
                                // Raw Materials - Sand (all types)
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "M-Sand • Zone I", quantity: "200", unitPrice: "800"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "M-Sand • Zone II", quantity: "300", unitPrice: "800"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Coarse)", quantity: "250", unitPrice: "1200"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Fine)", quantity: "150", unitPrice: "1100"),
                                
                                // Machines & Equipment (all types)
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-day hire", quantity: "25", unitPrice: "12000"),
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-hour hire", quantity: "100", unitPrice: "1500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Tractor / Trolley", spec: "Per-trip", quantity: "120", unitPrice: "800"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Tractor / Trolley", spec: "Per-day", quantity: "30", unitPrice: "2500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Concrete Mixer", spec: "Per-day hire", quantity: "30", unitPrice: "1500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Vibrator", spec: "Per-day hire", quantity: "25", unitPrice: "800"),
                                
                                // Labour (all types)
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Unskilled", quantity: "30", unitPrice: "500"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "15", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "20", unitPrice: "750"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Mason", quantity: "15", unitPrice: "900"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "25", unitPrice: "550")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Electrical",
                            contractorMode: .turnkey,
                            lineItems: [
                                // Wires & Cables (all sizes)
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "2.5 sq mm", quantity: "1000", unitPrice: "95"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "4 sq mm", quantity: "1500", unitPrice: "145"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "6 sq mm", quantity: "800", unitPrice: "220"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "10 sq mm", quantity: "400", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "16 sq mm", quantity: "200", unitPrice: "550"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "25 sq mm", quantity: "100", unitPrice: "850"),
                                
                                // Switches & Sockets (all types)
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Single pole", quantity: "80", unitPrice: "120"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Double pole", quantity: "60", unitPrice: "150"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Triple pole", quantity: "40", unitPrice: "180"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "5A socket", quantity: "50", unitPrice: "200"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "15A socket", quantity: "30", unitPrice: "250"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Modular switches", quantity: "100", unitPrice: "180"),
                                
                                // MCB & DB (all types)
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "6A MCB", quantity: "25", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "10A MCB", quantity: "40", unitPrice: "400"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "16A MCB", quantity: "50", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "20A MCB", quantity: "50", unitPrice: "550"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "32A MCB", quantity: "30", unitPrice: "650"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "Distribution Board", quantity: "12", unitPrice: "8500"),
                                
                                // Lighting (all types)
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Bulb", quantity: "150", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Tube", quantity: "100", unitPrice: "650"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Panel", quantity: "80", unitPrice: "1200"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Strip", quantity: "60", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "CFL", quantity: "40", unitPrice: "280"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "Halogen", quantity: "30", unitPrice: "400"),
                                
                                // Conduits & Accessories (all sizes)
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "20mm PVC", quantity: "400", unitPrice: "70"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "25mm PVC", quantity: "500", unitPrice: "85"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "32mm PVC", quantity: "500", unitPrice: "120"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "40mm PVC", quantity: "300", unitPrice: "150"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Elbow", quantity: "200", unitPrice: "45"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Coupler", quantity: "150", unitPrice: "35"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Bend", quantity: "100", unitPrice: "55"),
                                
                                // Labour
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Unskilled", quantity: "10", unitPrice: "500"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "5", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "8", unitPrice: "850"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "12", unitPrice: "550")
                            ]
                        ),
                        TemplateDepartment(
                            name: "HVAC",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-day hire", quantity: "10", unitPrice: "12000"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "6", unitPrice: "900"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "8", unitPrice: "550")
                            ]
                        )
                    ]
                ),
                TemplatePhase(
                    phaseName: "Interior Fit-out",
                    startDate: Calendar.current.date(byAdding: .day, value: 121, to: Date()) ?? Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 210, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 43", quantity: "150", unitPrice: "360"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Fine)", quantity: "80", unitPrice: "1100"),
                                TemplateLineItem(itemType: "Tiles", item: "Floor Tiles", spec: "Vitrified", quantity: "400", unitPrice: "95"),
                                TemplateLineItem(itemType: "Paint", item: "Interior Paint", spec: "Premium", quantity: "150", unitPrice: "520"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Mason", quantity: "8", unitPrice: "900"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "10", unitPrice: "750")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Electrical",
                            contractorMode: .turnkey,
                            lineItems: [
                                // Wires & Cables
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "1.5 sq mm", quantity: "400", unitPrice: "75"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "2.5 sq mm", quantity: "600", unitPrice: "95"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "4 sq mm", quantity: "300", unitPrice: "145"),
                                
                                // Switches & Sockets (all types)
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Single pole", quantity: "60", unitPrice: "120"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Double pole", quantity: "50", unitPrice: "150"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Triple pole", quantity: "40", unitPrice: "180"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "5A socket", quantity: "40", unitPrice: "200"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "15A socket", quantity: "80", unitPrice: "250"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Modular switches", quantity: "120", unitPrice: "180"),
                                
                                // MCB & DB
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "10A MCB", quantity: "30", unitPrice: "400"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "16A MCB", quantity: "40", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "20A MCB", quantity: "30", unitPrice: "550"),
                                
                                // Lighting (all types)
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Bulb", quantity: "100", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Tube", quantity: "80", unitPrice: "650"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Panel", quantity: "250", unitPrice: "1200"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Strip", quantity: "150", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "CFL", quantity: "50", unitPrice: "280"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "Halogen", quantity: "30", unitPrice: "400"),
                                
                                // Conduits & Accessories
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "20mm PVC", quantity: "300", unitPrice: "70"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "25mm PVC", quantity: "400", unitPrice: "85"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "32mm PVC", quantity: "200", unitPrice: "120"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Elbow", quantity: "150", unitPrice: "45"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Coupler", quantity: "120", unitPrice: "35"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "Bend", quantity: "100", unitPrice: "55"),
                                
                                // Labour
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "5", unitPrice: "850"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "3", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "6", unitPrice: "550")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Plumbing",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Plumbing", item: "CPVC Pipes", spec: "1 inch", quantity: "180", unitPrice: "145"),
                                TemplateLineItem(itemType: "Plumbing", item: "Fittings", spec: "Standard", quantity: "100", unitPrice: "55"),
                                TemplateLineItem(itemType: "Plumbing", item: "Fixtures", spec: "Premium", quantity: "35", unitPrice: "2200"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "4", unitPrice: "850")
                            ]
                        )
                    ]
                )
            ],
            allowTemplateOverrides: false
        ),
        
        // Template 3: Infrastructure Road Project (AVR Construction Budgets)
        ProjectTemplate(
            id: "infrastructure_road",
            name: "Road Infrastructure",
            description: "Template for road construction and infrastructure projects with AVR construction budgets",
            icon: "road.lanes",
            location: "",
            currency: "INR",
            plannedDate: Date(),
            phases: [
                TemplatePhase(
                    phaseName: "Earthwork & Base",
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "M-Sand • Zone I", quantity: "800", unitPrice: "800"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Coarse)", quantity: "600", unitPrice: "1200"),
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 53", quantity: "400", unitPrice: "380"),
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-day hire", quantity: "40", unitPrice: "12000"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Tractor / Trolley", spec: "Per-trip", quantity: "200", unitPrice: "800"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Concrete Mixer", spec: "Per-day hire", quantity: "25", unitPrice: "1500"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "15", unitPrice: "750"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "30", unitPrice: "550")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Labour",
                            contractorMode: .labourOnly,
                            lineItems: [
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Semi-skilled", quantity: "8", unitPrice: "650"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "25", unitPrice: "550")
                            ]
                        )
                    ]
                ),
                TemplatePhase(
                    phaseName: "Pavement & Marking",
                    startDate: Calendar.current.date(byAdding: .day, value: 61, to: Date()) ?? Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 120, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 53", quantity: "600", unitPrice: "380"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "M-Sand • Zone II", quantity: "400", unitPrice: "800"),
                                TemplateLineItem(itemType: "Raw material", item: "Steel", spec: "Fe500 • 12 mm", quantity: "20", unitPrice: "62000"),
                                TemplateLineItem(itemType: "Paint", item: "Road Marking Paint", spec: "Thermoplastic", quantity: "150", unitPrice: "220"),
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-day hire", quantity: "20", unitPrice: "12000"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Concrete Mixer", spec: "Per-day hire", quantity: "30", unitPrice: "1500"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Vibrator", spec: "Per-day hire", quantity: "25", unitPrice: "800"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Mason", quantity: "10", unitPrice: "900"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "12", unitPrice: "750")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Electrical",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "4 sq mm", quantity: "300", unitPrice: "145"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Bulb", quantity: "100", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "Distribution Board", quantity: "5", unitPrice: "8500"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "3", unitPrice: "850")
                            ]
                        )
                    ]
                )
            ],
            allowTemplateOverrides: false
        ),
        
        // Template 4: Renovation Project (AVR Construction Budgets)
        ProjectTemplate(
            id: "renovation",
            name: "Renovation",
            description: "Template for building renovation and remodeling projects with AVR construction budgets",
            icon: "hammer.fill",
            location: "",
            currency: "INR",
            plannedDate: Date(),
            phases: [
                TemplatePhase(
                    phaseName: "Demolition & Preparation",
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .labourOnly,
                            lineItems: [
                                TemplateLineItem(itemType: "Machines & eq", item: "JCB", spec: "Per-day hire", quantity: "8", unitPrice: "12000"),
                                TemplateLineItem(itemType: "Machines & eq", item: "Tractor / Trolley", spec: "Per-trip", quantity: "30", unitPrice: "800"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "6", unitPrice: "750"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Helper", quantity: "12", unitPrice: "550")
                            ]
                        )
                    ]
                ),
                TemplatePhase(
                    phaseName: "Renovation Work",
                    startDate: Calendar.current.date(byAdding: .day, value: 31, to: Date()) ?? Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 90, to: Date()) ?? Date(),
                    departments: [
                        TemplateDepartment(
                            name: "Civil",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Raw material", item: "Cement", spec: "OPC 43", quantity: "150", unitPrice: "360"),
                                TemplateLineItem(itemType: "Raw material", item: "Sand", spec: "River Sand (Fine)", quantity: "100", unitPrice: "1100"),
                                TemplateLineItem(itemType: "Tiles", item: "Wall Tiles", spec: "Ceramic", quantity: "180", unitPrice: "95"),
                                TemplateLineItem(itemType: "Tiles", item: "Floor Tiles", spec: "Vitrified", quantity: "120", unitPrice: "85"),
                                TemplateLineItem(itemType: "Paint", item: "Interior Paint", spec: "Premium", quantity: "90", unitPrice: "520"),
                                TemplateLineItem(itemType: "Paint", item: "Exterior Paint", spec: "Weatherproof", quantity: "60", unitPrice: "680"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Mason", quantity: "5", unitPrice: "900"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "6", unitPrice: "750")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Electrical",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "2.5 sq mm", quantity: "400", unitPrice: "95"),
                                TemplateLineItem(itemType: "Electrical", item: "Wires & Cables", spec: "4 sq mm", quantity: "200", unitPrice: "145"),
                                TemplateLineItem(itemType: "Electrical", item: "Switches & Sockets", spec: "Modular switches", quantity: "40", unitPrice: "180"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "Distribution Board", quantity: "2", unitPrice: "8500"),
                                TemplateLineItem(itemType: "Electrical", item: "MCB & DB", spec: "16A MCB", quantity: "15", unitPrice: "450"),
                                TemplateLineItem(itemType: "Electrical", item: "Lighting", spec: "LED Bulb", quantity: "60", unitPrice: "350"),
                                TemplateLineItem(itemType: "Electrical", item: "Conduits & Accessories", spec: "25mm PVC", quantity: "200", unitPrice: "85"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "3", unitPrice: "850")
                            ]
                        ),
                        TemplateDepartment(
                            name: "Plumbing",
                            contractorMode: .turnkey,
                            lineItems: [
                                TemplateLineItem(itemType: "Plumbing", item: "CPVC Pipes", spec: "1 inch", quantity: "120", unitPrice: "145"),
                                TemplateLineItem(itemType: "Plumbing", item: "Fittings", spec: "Standard", quantity: "80", unitPrice: "55"),
                                TemplateLineItem(itemType: "Plumbing", item: "Fixtures", spec: "Standard", quantity: "18", unitPrice: "2000"),
                                TemplateLineItem(itemType: "Labour", item: "Men & Women", spec: "Skilled", quantity: "2", unitPrice: "850")
                            ]
                        )
                    ]
                )
            ],
            allowTemplateOverrides: false
        )
    ]
}

