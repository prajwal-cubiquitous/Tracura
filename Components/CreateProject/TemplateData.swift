//
//  TemplateData.swift
//  Tracura
//
//  Created for template data storage
//  Edit this file to add, modify, or remove templates
//  All template data including phases, departments, and line items are stored here
//

import Foundation

// MARK: - Template Display Model
struct TemplateDisplayItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let businessType: String?
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
    // Structure: Template -> Phases -> Departments -> Line Items
    // Each line item contains: itemType, item, spec, quantity, uom, unitPrice
    // Each department contains: name, contractorMode ("Turnkey" or "Labour-Only"), lineItems
    // Each phase contains: phaseName, startDateDays (days from today), endDateDays (days from today), departments
    static let templateData: [String: [String: Any]] = [
        "residential_building": [
            "id": "residential_building",
            "icon": "house.fill",
            "title": "Residential Building",
            "description": "Standard template for residential building construction projects",
            "businessType": "Construction",
            "phasesCount": 2,
            "departmentsCount": 5,
            "phases": [
                [
                    "phaseName": "Foundation & Structure",
                    "startDateDays": 0,
                    "endDateDays": 90,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 53", "quantity": "500", "uom": "", "unitPrice": "380"],
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 43", "quantity": "200", "uom": "", "unitPrice": "360"],
                                ["itemType": "Raw material", "item": "Cement", "spec": "PPC", "quantity": "100", "uom": "", "unitPrice": "350"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 6 mm", "quantity": "10", "uom": "", "unitPrice": "58000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 8 mm", "quantity": "15", "uom": "", "unitPrice": "59000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 10 mm", "quantity": "20", "uom": "", "unitPrice": "60000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 12 mm", "quantity": "25", "uom": "", "unitPrice": "62000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 16 mm", "quantity": "30", "uom": "", "unitPrice": "62000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 20 mm", "quantity": "15", "uom": "", "unitPrice": "62000"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "M-Sand • Zone I", "quantity": "100", "uom": "", "unitPrice": "800"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "M-Sand • Zone II", "quantity": "150", "uom": "", "unitPrice": "800"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Coarse)", "quantity": "200", "uom": "", "unitPrice": "1200"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Fine)", "quantity": "100", "uom": "", "unitPrice": "1100"],
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-day hire", "quantity": "15", "uom": "", "unitPrice": "12000"],
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-hour hire", "quantity": "50", "uom": "", "unitPrice": "1500"],
                                ["itemType": "Machines & eq", "item": "Tractor / Trolley", "spec": "Per-trip", "quantity": "80", "uom": "", "unitPrice": "800"],
                                ["itemType": "Machines & eq", "item": "Tractor / Trolley", "spec": "Per-day", "quantity": "20", "uom": "", "unitPrice": "2500"],
                                ["itemType": "Machines & eq", "item": "Concrete Mixer", "spec": "Per-day hire", "quantity": "20", "uom": "", "unitPrice": "1500"],
                                ["itemType": "Machines & eq", "item": "Vibrator", "spec": "Per-day hire", "quantity": "15", "uom": "", "unitPrice": "800"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Unskilled", "quantity": "20", "uom": "", "unitPrice": "500"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "10", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "12", "uom": "", "unitPrice": "750"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Mason", "quantity": "8", "uom": "", "unitPrice": "900"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "15", "uom": "", "unitPrice": "550"]
                            ]
                        ],
                        [
                            "name": "Electrical",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "1.5 sq mm", "quantity": "500", "uom": "", "unitPrice": "75"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "2.5 sq mm", "quantity": "800", "uom": "", "unitPrice": "95"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "4 sq mm", "quantity": "400", "uom": "", "unitPrice": "145"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "6 sq mm", "quantity": "200", "uom": "", "unitPrice": "220"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "10 sq mm", "quantity": "100", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "16 sq mm", "quantity": "50", "uom": "", "unitPrice": "550"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "25 sq mm", "quantity": "30", "uom": "", "unitPrice": "850"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Single pole", "quantity": "40", "uom": "", "unitPrice": "120"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Double pole", "quantity": "30", "uom": "", "unitPrice": "150"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Triple pole", "quantity": "20", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "5A socket", "quantity": "25", "uom": "", "unitPrice": "200"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "15A socket", "quantity": "15", "uom": "", "unitPrice": "250"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Modular switches", "quantity": "60", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "6A MCB", "quantity": "15", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "10A MCB", "quantity": "20", "uom": "", "unitPrice": "400"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "16A MCB", "quantity": "20", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "20A MCB", "quantity": "15", "uom": "", "unitPrice": "550"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "32A MCB", "quantity": "10", "uom": "", "unitPrice": "650"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "Distribution Board", "quantity": "4", "uom": "", "unitPrice": "8500"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Bulb", "quantity": "60", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Tube", "quantity": "40", "uom": "", "unitPrice": "650"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Panel", "quantity": "50", "uom": "", "unitPrice": "1200"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Strip", "quantity": "30", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "CFL", "quantity": "20", "uom": "", "unitPrice": "280"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "Halogen", "quantity": "15", "uom": "", "unitPrice": "400"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "20mm PVC", "quantity": "200", "uom": "", "unitPrice": "70"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "25mm PVC", "quantity": "300", "uom": "", "unitPrice": "85"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "32mm PVC", "quantity": "150", "uom": "", "unitPrice": "120"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "40mm PVC", "quantity": "100", "uom": "", "unitPrice": "150"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Elbow", "quantity": "80", "uom": "", "unitPrice": "45"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Coupler", "quantity": "60", "uom": "", "unitPrice": "35"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Bend", "quantity": "50", "uom": "", "unitPrice": "55"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "4", "uom": "", "unitPrice": "850"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "3", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "5", "uom": "", "unitPrice": "550"]
                            ]
                        ]
                    ]
                ],
                [
                    "phaseName": "Finishing & Interior",
                    "startDateDays": 91,
                    "endDateDays": 180,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 43", "quantity": "200", "uom": "", "unitPrice": "360"],
                                ["itemType": "Raw material", "item": "Cement", "spec": "PPC", "quantity": "100", "uom": "", "unitPrice": "350"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Fine)", "quantity": "100", "uom": "", "unitPrice": "1100"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "M-Sand • Zone II", "quantity": "80", "uom": "", "unitPrice": "800"],
                                ["itemType": "Tiles", "item": "Floor Tiles", "spec": "Vitrified", "quantity": "250", "uom": "", "unitPrice": "85"],
                                ["itemType": "Tiles", "item": "Wall Tiles", "spec": "Ceramic", "quantity": "180", "uom": "", "unitPrice": "95"],
                                ["itemType": "Paint", "item": "Interior Paint", "spec": "Premium", "quantity": "120", "uom": "", "unitPrice": "520"],
                                ["itemType": "Paint", "item": "Exterior Paint", "spec": "Weatherproof", "quantity": "80", "uom": "", "unitPrice": "680"],
                                ["itemType": "Machines & eq", "item": "Concrete Mixer", "spec": "Per-day hire", "quantity": "10", "uom": "", "unitPrice": "1500"],
                                ["itemType": "Machines & eq", "item": "Vibrator", "spec": "Per-day hire", "quantity": "8", "uom": "", "unitPrice": "800"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Unskilled", "quantity": "10", "uom": "", "unitPrice": "500"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "5", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "8", "uom": "", "unitPrice": "750"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Mason", "quantity": "6", "uom": "", "unitPrice": "900"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "8", "uom": "", "unitPrice": "550"]
                            ]
                        ],
                        [
                            "name": "Plumbing",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Plumbing", "item": "CPVC Pipes", "spec": "1 inch", "quantity": "250", "uom": "", "unitPrice": "145"],
                                ["itemType": "Plumbing", "item": "Fittings", "spec": "Standard", "quantity": "120", "uom": "", "unitPrice": "55"],
                                ["itemType": "Plumbing", "item": "Fixtures", "spec": "Premium", "quantity": "25", "uom": "", "unitPrice": "2200"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "3", "uom": "", "unitPrice": "850"]
                            ]
                        ],
                        [
                            "name": "Electrical",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "1.5 sq mm", "quantity": "300", "uom": "", "unitPrice": "75"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "2.5 sq mm", "quantity": "400", "uom": "", "unitPrice": "95"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "4 sq mm", "quantity": "200", "uom": "", "unitPrice": "145"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Single pole", "quantity": "25", "uom": "", "unitPrice": "120"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Modular switches", "quantity": "40", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "15A socket", "quantity": "20", "uom": "", "unitPrice": "250"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "16A MCB", "quantity": "15", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "20A MCB", "quantity": "10", "uom": "", "unitPrice": "550"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Bulb", "quantity": "80", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Tube", "quantity": "25", "uom": "", "unitPrice": "650"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Panel", "quantity": "30", "uom": "", "unitPrice": "1200"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Strip", "quantity": "20", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "CFL", "quantity": "15", "uom": "", "unitPrice": "280"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "20mm PVC", "quantity": "150", "uom": "", "unitPrice": "70"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "25mm PVC", "quantity": "200", "uom": "", "unitPrice": "85"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Elbow", "quantity": "50", "uom": "", "unitPrice": "45"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Coupler", "quantity": "40", "uom": "", "unitPrice": "35"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "2", "uom": "", "unitPrice": "850"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "2", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "3", "uom": "", "unitPrice": "550"]
                            ]
                        ]
                    ]
                ]
            ]
        ],
        "commercial_office": [
            "id": "commercial_office",
            "icon": "building.2.fill",
            "title": "Commercial Office",
            "description": "Template for commercial office space construction and fit-out",
            "businessType": "Construction",
            "phasesCount": 2,
            "departmentsCount": 6,
            "phases": [
                [
                    "phaseName": "Shell & Core",
                    "startDateDays": 0,
                    "endDateDays": 120,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 53", "quantity": "800", "uom": "", "unitPrice": "380"],
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 43", "quantity": "300", "uom": "", "unitPrice": "360"],
                                ["itemType": "Raw material", "item": "Cement", "spec": "PPC", "quantity": "200", "uom": "", "unitPrice": "350"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 10 mm", "quantity": "40", "uom": "", "unitPrice": "60000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 12 mm", "quantity": "50", "uom": "", "unitPrice": "62000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 16 mm", "quantity": "60", "uom": "", "unitPrice": "62000"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 20 mm", "quantity": "50", "uom": "", "unitPrice": "62000"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "M-Sand • Zone I", "quantity": "200", "uom": "", "unitPrice": "800"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "M-Sand • Zone II", "quantity": "300", "uom": "", "unitPrice": "800"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Coarse)", "quantity": "250", "uom": "", "unitPrice": "1200"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Fine)", "quantity": "150", "uom": "", "unitPrice": "1100"],
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-day hire", "quantity": "25", "uom": "", "unitPrice": "12000"],
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-hour hire", "quantity": "100", "uom": "", "unitPrice": "1500"],
                                ["itemType": "Machines & eq", "item": "Tractor / Trolley", "spec": "Per-trip", "quantity": "120", "uom": "", "unitPrice": "800"],
                                ["itemType": "Machines & eq", "item": "Tractor / Trolley", "spec": "Per-day", "quantity": "30", "uom": "", "unitPrice": "2500"],
                                ["itemType": "Machines & eq", "item": "Concrete Mixer", "spec": "Per-day hire", "quantity": "30", "uom": "", "unitPrice": "1500"],
                                ["itemType": "Machines & eq", "item": "Vibrator", "spec": "Per-day hire", "quantity": "25", "uom": "", "unitPrice": "800"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Unskilled", "quantity": "30", "uom": "", "unitPrice": "500"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "15", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "20", "uom": "", "unitPrice": "750"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Mason", "quantity": "15", "uom": "", "unitPrice": "900"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "25", "uom": "", "unitPrice": "550"]
                            ]
                        ],
                        [
                            "name": "Electrical",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "2.5 sq mm", "quantity": "1000", "uom": "", "unitPrice": "95"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "4 sq mm", "quantity": "1500", "uom": "", "unitPrice": "145"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "6 sq mm", "quantity": "800", "uom": "", "unitPrice": "220"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "10 sq mm", "quantity": "400", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "16 sq mm", "quantity": "200", "uom": "", "unitPrice": "550"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "25 sq mm", "quantity": "100", "uom": "", "unitPrice": "850"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Single pole", "quantity": "80", "uom": "", "unitPrice": "120"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Double pole", "quantity": "60", "uom": "", "unitPrice": "150"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Triple pole", "quantity": "40", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "5A socket", "quantity": "50", "uom": "", "unitPrice": "200"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "15A socket", "quantity": "30", "uom": "", "unitPrice": "250"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Modular switches", "quantity": "100", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "6A MCB", "quantity": "25", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "10A MCB", "quantity": "40", "uom": "", "unitPrice": "400"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "16A MCB", "quantity": "50", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "20A MCB", "quantity": "50", "uom": "", "unitPrice": "550"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "32A MCB", "quantity": "30", "uom": "", "unitPrice": "650"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "Distribution Board", "quantity": "12", "uom": "", "unitPrice": "8500"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Bulb", "quantity": "150", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Tube", "quantity": "100", "uom": "", "unitPrice": "650"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Panel", "quantity": "80", "uom": "", "unitPrice": "1200"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Strip", "quantity": "60", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "CFL", "quantity": "40", "uom": "", "unitPrice": "280"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "Halogen", "quantity": "30", "uom": "", "unitPrice": "400"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "20mm PVC", "quantity": "400", "uom": "", "unitPrice": "70"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "25mm PVC", "quantity": "500", "uom": "", "unitPrice": "85"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "32mm PVC", "quantity": "500", "uom": "", "unitPrice": "120"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "40mm PVC", "quantity": "300", "uom": "", "unitPrice": "150"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Elbow", "quantity": "200", "uom": "", "unitPrice": "45"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Coupler", "quantity": "150", "uom": "", "unitPrice": "35"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Bend", "quantity": "100", "uom": "", "unitPrice": "55"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Unskilled", "quantity": "10", "uom": "", "unitPrice": "500"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "5", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "8", "uom": "", "unitPrice": "850"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "12", "uom": "", "unitPrice": "550"]
                            ]
                        ],
                        [
                            "name": "HVAC",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-day hire", "quantity": "10", "uom": "", "unitPrice": "12000"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "6", "uom": "", "unitPrice": "900"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "8", "uom": "", "unitPrice": "550"]
                            ]
                        ]
                    ]
                ],
                [
                    "phaseName": "Interior Fit-out",
                    "startDateDays": 121,
                    "endDateDays": 210,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 43", "quantity": "150", "uom": "", "unitPrice": "360"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Fine)", "quantity": "80", "uom": "", "unitPrice": "1100"],
                                ["itemType": "Tiles", "item": "Floor Tiles", "spec": "Vitrified", "quantity": "400", "uom": "", "unitPrice": "95"],
                                ["itemType": "Paint", "item": "Interior Paint", "spec": "Premium", "quantity": "150", "uom": "", "unitPrice": "520"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Mason", "quantity": "8", "uom": "", "unitPrice": "900"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "10", "uom": "", "unitPrice": "750"]
                            ]
                        ],
                        [
                            "name": "Electrical",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "1.5 sq mm", "quantity": "400", "uom": "", "unitPrice": "75"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "2.5 sq mm", "quantity": "600", "uom": "", "unitPrice": "95"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "4 sq mm", "quantity": "300", "uom": "", "unitPrice": "145"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Single pole", "quantity": "60", "uom": "", "unitPrice": "120"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Double pole", "quantity": "50", "uom": "", "unitPrice": "150"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Triple pole", "quantity": "40", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "5A socket", "quantity": "40", "uom": "", "unitPrice": "200"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "15A socket", "quantity": "80", "uom": "", "unitPrice": "250"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Modular switches", "quantity": "120", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "10A MCB", "quantity": "30", "uom": "", "unitPrice": "400"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "16A MCB", "quantity": "40", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "20A MCB", "quantity": "30", "uom": "", "unitPrice": "550"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Bulb", "quantity": "100", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Tube", "quantity": "80", "uom": "", "unitPrice": "650"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Panel", "quantity": "250", "uom": "", "unitPrice": "1200"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Strip", "quantity": "150", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "CFL", "quantity": "50", "uom": "", "unitPrice": "280"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "Halogen", "quantity": "30", "uom": "", "unitPrice": "400"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "20mm PVC", "quantity": "300", "uom": "", "unitPrice": "70"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "25mm PVC", "quantity": "400", "uom": "", "unitPrice": "85"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "32mm PVC", "quantity": "200", "uom": "", "unitPrice": "120"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Elbow", "quantity": "150", "uom": "", "unitPrice": "45"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Coupler", "quantity": "120", "uom": "", "unitPrice": "35"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "Bend", "quantity": "100", "uom": "", "unitPrice": "55"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "5", "uom": "", "unitPrice": "850"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "3", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "6", "uom": "", "unitPrice": "550"]
                            ]
                        ],
                        [
                            "name": "Plumbing",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Plumbing", "item": "CPVC Pipes", "spec": "1 inch", "quantity": "180", "uom": "", "unitPrice": "145"],
                                ["itemType": "Plumbing", "item": "Fittings", "spec": "Standard", "quantity": "100", "uom": "", "unitPrice": "55"],
                                ["itemType": "Plumbing", "item": "Fixtures", "spec": "Premium", "quantity": "35", "uom": "", "unitPrice": "2200"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "4", "uom": "", "unitPrice": "850"]
                            ]
                        ]
                    ]
                ]
            ]
        ],
        "road_infrastructure": [
            "id": "road_infrastructure",
            "icon": "road.lanes",
            "title": "Road Infrastructure",
            "description": "Template for road construction and infrastructure projects",
            "businessType": "Construction",
            "phasesCount": 2,
            "departmentsCount": 4,
            "phases": [
                [
                    "phaseName": "Earthwork & Base",
                    "startDateDays": 0,
                    "endDateDays": 60,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Raw material", "item": "Sand", "spec": "M-Sand • Zone I", "quantity": "800", "uom": "", "unitPrice": "800"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Coarse)", "quantity": "600", "uom": "", "unitPrice": "1200"],
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 53", "quantity": "400", "uom": "", "unitPrice": "380"],
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-day hire", "quantity": "40", "uom": "", "unitPrice": "12000"],
                                ["itemType": "Machines & eq", "item": "Tractor / Trolley", "spec": "Per-trip", "quantity": "200", "uom": "", "unitPrice": "800"],
                                ["itemType": "Machines & eq", "item": "Concrete Mixer", "spec": "Per-day hire", "quantity": "25", "uom": "", "unitPrice": "1500"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "15", "uom": "", "unitPrice": "750"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "30", "uom": "", "unitPrice": "550"]
                            ]
                        ],
                        [
                            "name": "Labour",
                            "contractorMode": "Labour-Only",
                            "lineItems": [
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Semi-skilled", "quantity": "8", "uom": "", "unitPrice": "650"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "25", "uom": "", "unitPrice": "550"]
                            ]
                        ]
                    ]
                ],
                [
                    "phaseName": "Pavement & Marking",
                    "startDateDays": 61,
                    "endDateDays": 120,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 53", "quantity": "600", "uom": "", "unitPrice": "380"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "M-Sand • Zone II", "quantity": "400", "uom": "", "unitPrice": "800"],
                                ["itemType": "Raw material", "item": "Steel", "spec": "Fe500 • 12 mm", "quantity": "20", "uom": "", "unitPrice": "62000"],
                                ["itemType": "Paint", "item": "Road Marking Paint", "spec": "Thermoplastic", "quantity": "150", "uom": "", "unitPrice": "220"],
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-day hire", "quantity": "20", "uom": "", "unitPrice": "12000"],
                                ["itemType": "Machines & eq", "item": "Concrete Mixer", "spec": "Per-day hire", "quantity": "30", "uom": "", "unitPrice": "1500"],
                                ["itemType": "Machines & eq", "item": "Vibrator", "spec": "Per-day hire", "quantity": "25", "uom": "", "unitPrice": "800"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Mason", "quantity": "10", "uom": "", "unitPrice": "900"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "12", "uom": "", "unitPrice": "750"]
                            ]
                        ],
                        [
                            "name": "Electrical",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "4 sq mm", "quantity": "300", "uom": "", "unitPrice": "145"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Bulb", "quantity": "100", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "Distribution Board", "quantity": "5", "uom": "", "unitPrice": "8500"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "3", "uom": "", "unitPrice": "850"]
                            ]
                        ]
                    ]
                ]
            ]
        ],
        "renovation": [
            "id": "renovation",
            "icon": "hammer.fill",
            "title": "Renovation",
            "description": "Template for building renovation and remodeling projects",
            "businessType": "Construction",
            "phasesCount": 2,
            "departmentsCount": 4,
            "phases": [
                [
                    "phaseName": "Demolition & Preparation",
                    "startDateDays": 0,
                    "endDateDays": 30,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Labour-Only",
                            "lineItems": [
                                ["itemType": "Machines & eq", "item": "JCB", "spec": "Per-day hire", "quantity": "8", "uom": "", "unitPrice": "12000"],
                                ["itemType": "Machines & eq", "item": "Tractor / Trolley", "spec": "Per-trip", "quantity": "30", "uom": "", "unitPrice": "800"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "6", "uom": "", "unitPrice": "750"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Helper", "quantity": "12", "uom": "", "unitPrice": "550"]
                            ]
                        ]
                    ]
                ],
                [
                    "phaseName": "Renovation Work",
                    "startDateDays": 31,
                    "endDateDays": 90,
                    "departments": [
                        [
                            "name": "Civil",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Raw material", "item": "Cement", "spec": "OPC 43", "quantity": "150", "uom": "", "unitPrice": "360"],
                                ["itemType": "Raw material", "item": "Sand", "spec": "River Sand (Fine)", "quantity": "100", "uom": "", "unitPrice": "1100"],
                                ["itemType": "Tiles", "item": "Wall Tiles", "spec": "Ceramic", "quantity": "180", "uom": "", "unitPrice": "95"],
                                ["itemType": "Tiles", "item": "Floor Tiles", "spec": "Vitrified", "quantity": "120", "uom": "", "unitPrice": "85"],
                                ["itemType": "Paint", "item": "Interior Paint", "spec": "Premium", "quantity": "90", "uom": "", "unitPrice": "520"],
                                ["itemType": "Paint", "item": "Exterior Paint", "spec": "Weatherproof", "quantity": "60", "uom": "", "unitPrice": "680"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Mason", "quantity": "5", "uom": "", "unitPrice": "900"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "6", "uom": "", "unitPrice": "750"]
                            ]
                        ],
                        [
                            "name": "Electrical",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "2.5 sq mm", "quantity": "400", "uom": "", "unitPrice": "95"],
                                ["itemType": "Electrical", "item": "Wires & Cables", "spec": "4 sq mm", "quantity": "200", "uom": "", "unitPrice": "145"],
                                ["itemType": "Electrical", "item": "Switches & Sockets", "spec": "Modular switches", "quantity": "40", "uom": "", "unitPrice": "180"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "Distribution Board", "quantity": "2", "uom": "", "unitPrice": "8500"],
                                ["itemType": "Electrical", "item": "MCB & DB", "spec": "16A MCB", "quantity": "15", "uom": "", "unitPrice": "450"],
                                ["itemType": "Electrical", "item": "Lighting", "spec": "LED Bulb", "quantity": "60", "uom": "", "unitPrice": "350"],
                                ["itemType": "Electrical", "item": "Conduits & Accessories", "spec": "25mm PVC", "quantity": "200", "uom": "", "unitPrice": "85"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "3", "uom": "", "unitPrice": "850"]
                            ]
                        ],
                        [
                            "name": "Plumbing",
                            "contractorMode": "Turnkey",
                            "lineItems": [
                                ["itemType": "Plumbing", "item": "CPVC Pipes", "spec": "1 inch", "quantity": "120", "uom": "", "unitPrice": "145"],
                                ["itemType": "Plumbing", "item": "Fittings", "spec": "Standard", "quantity": "80", "uom": "", "unitPrice": "55"],
                                ["itemType": "Plumbing", "item": "Fixtures", "spec": "Standard", "quantity": "18", "uom": "", "unitPrice": "2000"],
                                ["itemType": "Labour", "item": "Men & Women", "spec": "Skilled", "quantity": "2", "uom": "", "unitPrice": "850"]
                            ]
                        ]
                    ]
                ]
            ]
        ],
        
        // MARK: - Interior Design Templates
        "interior_design_residential": [
                "id": "interior_design_residential",
                "icon": "paintbrush.fill",
                "title": "Residential Interior Design",
                "description": "Comprehensive interior design template for 3BHK residential apartment including woodwork, false ceiling, and finishing.",
                "businessType": "Interior Design",
                "phasesCount": 3,
                "departmentsCount": 5,
                "phases": [
                    [
                        "phaseName": "Design & Civil Changes",
                        "startDateDays": 0,
                        "endDateDays": 30,
                        "departments": [
                            [
                                "name": "Design Studio",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Service", "item": "Design Consultation", "spec": "3D Rendering & Layout", "quantity": "1", "uom": "Unit", "unitPrice": "45000"],
                                    ["itemType": "Service", "item": "2D Drawings", "spec": "Electrical & Plumbing Layouts", "quantity": "1", "uom": "Set", "unitPrice": "15000"]
                                ]
                            ],
                            [
                                "name": "Civil Work",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Raw material", "item": "Brickwork", "spec": "Partition Walls", "quantity": "150", "uom": "Sqft", "unitPrice": "120"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Demolition Crew", "quantity": "4", "uom": "Per Day", "unitPrice": "600"],
                                    ["itemType": "Machines & eq", "item": "Debris Removal", "spec": "Tractor Trip", "quantity": "3", "uom": "Per Trip", "unitPrice": "1200"]
                                ]
                            ]
                        ]
                    ],
                    [
                        "phaseName": "Woodwork & False Ceiling",
                        "startDateDays": 31,
                        "endDateDays": 90,
                        "departments": [
                            [
                                "name": "Carpentry",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Carpentry", "item": "Plywood", "spec": "BWP Grade 19mm", "quantity": "80", "uom": "Sheet", "unitPrice": "3200"],
                                    ["itemType": "Carpentry", "item": "Laminate", "spec": "1mm Glossy/Matte", "quantity": "120", "uom": "Sheet", "unitPrice": "1800"],
                                    ["itemType": "Carpentry", "item": "Hardware", "spec": "Hettich/Hafele Hinges & Channels", "quantity": "1", "uom": "Set", "unitPrice": "45000"],
                                    ["itemType": "Carpentry", "item": "Kitchen Unit", "spec": "Modular Carcass", "quantity": "60", "uom": "Sqft", "unitPrice": "1400"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Carpenter Head", "quantity": "45", "uom": "Per Day", "unitPrice": "1200"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Carpenter Helper", "quantity": "45", "uom": "Per Day", "unitPrice": "700"]
                                ]
                            ],
                            [
                                "name": "False Ceiling",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "False Ceiling", "item": "Gypsum Board", "spec": "Saint-Gobain/USG", "quantity": "1200", "uom": "Sqft", "unitPrice": "75"],
                                    ["itemType": "False Ceiling", "item": "Channels & Framing", "spec": "GI Sections", "quantity": "1200", "uom": "Sqft", "unitPrice": "45"],
                                    ["itemType": "Electrical", "item": "Wiring", "spec": "Ceiling Loop 1.5mm", "quantity": "6", "uom": "Bundle", "unitPrice": "1200"]
                                ]
                            ]
                        ]
                    ],
                    [
                        "phaseName": "Finishing & Handover",
                        "startDateDays": 91,
                        "endDateDays": 120,
                        "departments": [
                            [
                                "name": "Paint & Polish",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Paint", "item": "Wall Putty", "spec": "Acrylic", "quantity": "10", "uom": "Bag", "unitPrice": "850"],
                                    ["itemType": "Paint", "item": "Interior Paint", "spec": "Royal Emulsion", "quantity": "60", "uom": "Litre", "unitPrice": "650"],
                                    ["itemType": "Paint", "item": "PU Polish", "spec": "For Veneer Finishes", "quantity": "20", "uom": "Litre", "unitPrice": "1200"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Painter", "quantity": "15", "uom": "Per Day", "unitPrice": "900"]
                                ]
                            ],
                            [
                                "name": "Electrical & Decor",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Electrical", "item": "Light Fixtures", "spec": "COB Lights 12W", "quantity": "40", "uom": "Nos", "unitPrice": "450"],
                                    ["itemType": "Electrical", "item": "Light Fixtures", "spec": "Profile Light 2m", "quantity": "10", "uom": "Nos", "unitPrice": "1800"],
                                    ["itemType": "Furniture", "item": "Curtains & Blinds", "spec": "Custom Fabric", "quantity": "1", "uom": "Set", "unitPrice": "35000"],
                                    ["itemType": "Service", "item": "Deep Cleaning", "spec": "Post-Construction", "quantity": "1", "uom": "Unit", "unitPrice": "8000"]
                                ]
                            ]
                        ]
                    ]
                ]
            ],
        
        // MARK: - Media Templates
        "media_production_ad_film": [
                "id": "media_production_ad_film",
                "icon": "film.fill",
                "title": "Ad Film Production",
                "description": "Template for TV Commercial/Digital Ad Film production including pre-production, shoot, and post-production.",
                "businessType": "Media",
                "phasesCount": 3,
                "departmentsCount": 6,
                "phases": [
                    [
                        "phaseName": "Pre-Production",
                        "startDateDays": 0,
                        "endDateDays": 15,
                        "departments": [
                            [
                                "name": "Creative & Planning",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Service", "item": "Scripting", "spec": "Screenplay & Dialogues", "quantity": "1", "uom": "Unit", "unitPrice": "25000"],
                                    ["itemType": "Service", "item": "Storyboard", "spec": "Artist Illustrations", "quantity": "1", "uom": "Set", "unitPrice": "15000"],
                                    ["itemType": "Service", "item": "Location Scouting", "spec": "Recce Expenses", "quantity": "3", "uom": "Day", "unitPrice": "5000"],
                                    ["itemType": "Service", "item": "Casting Director", "spec": "Talent Sourcing", "quantity": "1", "uom": "Project", "unitPrice": "20000"]
                                ]
                            ]
                        ]
                    ],
                    [
                        "phaseName": "Production (Shoot)",
                        "startDateDays": 16,
                        "endDateDays": 20,
                        "departments": [
                            [
                                "name": "Camera & Lighting",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Equipment", "item": "Camera Body", "spec": "Arri Alexa / RED", "quantity": "2", "uom": "Shift", "unitPrice": "45000"],
                                    ["itemType": "Equipment", "item": "Lens Kit", "spec": "Prime Lenses Set", "quantity": "1", "uom": "Shift", "unitPrice": "15000"],
                                    ["itemType": "Equipment", "item": "Lights", "spec": "HMI & Skypanel Kit", "quantity": "1", "uom": "Shift", "unitPrice": "25000"],
                                    ["itemType": "Equipment", "item": "Grip Equipment", "spec": "Dolly/Track/Jimmy Jib", "quantity": "1", "uom": "Shift", "unitPrice": "12000"]
                                ]
                            ],
                            [
                                "name": "Crew & Talent",
                                "contractorMode": "Labour-Only",
                                "lineItems": [
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "DOP (Director of Photography)", "quantity": "2", "uom": "Shift", "unitPrice": "35000"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Director", "quantity": "2", "uom": "Shift", "unitPrice": "50000"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Gaffer/Lightman", "quantity": "4", "uom": "Shift", "unitPrice": "2500"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Makeup Artist", "quantity": "1", "uom": "Shift", "unitPrice": "8000"],
                                    ["itemType": "Labour", "item": "Men & Women", "spec": "Lead Actor/Actress", "quantity": "2", "uom": "Shift", "unitPrice": "40000"],
                                    ["itemType": "Service", "item": "Catering", "spec": "Crew Meals", "quantity": "50", "uom": "Plate", "unitPrice": "400"]
                                ]
                            ],
                            [
                                "name": "Art Department",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Raw material", "item": "Set Construction", "spec": "Wood/Paint/Backdrops", "quantity": "1", "uom": "Project", "unitPrice": "60000"],
                                    ["itemType": "Prop", "item": "Props Sourcing", "spec": "Furniture & Decor", "quantity": "1", "uom": "Lumpsum", "unitPrice": "20000"]
                                ]
                            ]
                        ]
                    ],
                    [
                        "phaseName": "Post-Production",
                        "startDateDays": 21,
                        "endDateDays": 45,
                        "departments": [
                            [
                                "name": "Edit & DI",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Service", "item": "Offline Edit", "spec": "FCP/Premiere Pro", "quantity": "5", "uom": "Day", "unitPrice": "8000"],
                                    ["itemType": "Service", "item": "Color Grading (DI)", "spec": "DaVinci Resolve Studio", "quantity": "10", "uom": "Hour", "unitPrice": "3500"],
                                    ["itemType": "Service", "item": "VFX/CGI", "spec": "Compositing/Cleanup", "quantity": "1", "uom": "Project", "unitPrice": "40000"]
                                ]
                            ],
                            [
                                "name": "Sound Design",
                                "contractorMode": "Turnkey",
                                "lineItems": [
                                    ["itemType": "Service", "item": "Music Composition", "spec": "Original Score", "quantity": "1", "uom": "Track", "unitPrice": "25000"],
                                    ["itemType": "Service", "item": "Voice Over", "spec": "Professional Artist", "quantity": "1", "uom": "Session", "unitPrice": "10000"],
                                    ["itemType": "Service", "item": "Mixing & Mastering", "spec": "Stereo/5.1 Mix", "quantity": "1", "uom": "Project", "unitPrice": "15000"]
                                ]
                            ]
                        ]
                    ]
                ]
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
            
            let businessType = value["businessType"] as? String
            
            return TemplateDisplayItem(
                id: id,
                icon: icon,
                title: title,
                description: description,
                businessType: businessType,
                phasesCount: phasesCount,
                departmentsCount: departmentsCount
            )
        }
        .sorted { $0.title < $1.title }
    }
    
    // MARK: - Get Templates by Business Type
    static func getTemplatesByBusinessType(_ businessType: String?) -> [TemplateDisplayItem] {
        let allTemplates = getAllTemplates()
        
        // If businessType is nil or empty, return all templates
        guard let businessType = businessType, !businessType.isEmpty else {
            return allTemplates
        }
        
        // Filter templates that match the businessType
        return allTemplates.filter { template in
            template.businessType?.lowercased() == businessType.lowercased()
        }
    }
    
    // MARK: - Get Default UOM based on ItemType and Item
    static func getDefaultUOM(itemType: String, item: String, spec: String = "") -> String {
        // If UOM options are available, get the first/default one
        let availableUOMs = DepartmentItemData.uomOptions(for: itemType)
        
        // Smart defaults based on itemType and item
        switch itemType {
        case "Raw material":
            switch item.lowercased() {
            case "cement":
                return availableUOMs.contains("Bag") ? "Bag" : (availableUOMs.first ?? "")
            case "steel":
                return availableUOMs.contains("KG") ? "KG" : (availableUOMs.first ?? "")
            case "sand":
                return availableUOMs.contains("m³") ? "m³" : (availableUOMs.contains("Cft") ? "Cft" : (availableUOMs.first ?? ""))
            case "aggregates":
                return availableUOMs.contains("m³") ? "m³" : (availableUOMs.contains("Cft") ? "Cft" : (availableUOMs.first ?? ""))
            case "bricks":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.first ?? "")
            case "water":
                return availableUOMs.contains("Litre") ? "Litre" : (availableUOMs.first ?? "")
            default:
                return availableUOMs.first ?? ""
            }
            
        case "Labour":
            // Check spec for labour type
            if spec.lowercased().contains("per-day") || spec.lowercased().contains("per day") {
                return availableUOMs.contains("Per Day") ? "Per Day" : (availableUOMs.first ?? "")
            } else if spec.lowercased().contains("per-hour") || spec.lowercased().contains("per hour") {
                return availableUOMs.contains("Per Hour") ? "Per Hour" : (availableUOMs.first ?? "")
            }
            return availableUOMs.contains("Per Day") ? "Per Day" : (availableUOMs.first ?? "")
            
        case "Machines & eq":
            // Check spec for hire type
            if spec.lowercased().contains("per-day") || spec.lowercased().contains("per day") {
                return availableUOMs.contains("Per Day") ? "Per Day" : (availableUOMs.first ?? "")
            } else if spec.lowercased().contains("per-hour") || spec.lowercased().contains("per hour") {
                return availableUOMs.contains("Per Hour") ? "Per Hour" : (availableUOMs.first ?? "")
            } else if spec.lowercased().contains("per-trip") || spec.lowercased().contains("per trip") {
                return availableUOMs.contains("Per Trip") ? "Per Trip" : (availableUOMs.first ?? "")
            }
            return availableUOMs.contains("Per Day") ? "Per Day" : (availableUOMs.first ?? "")
            
        case "Electrical":
            switch item.lowercased() {
            case "wires & cables", "wires", "cables":
                return availableUOMs.contains("m") ? "m" : (availableUOMs.contains("Rft") ? "Rft" : (availableUOMs.first ?? ""))
            case "switches & sockets", "switches", "sockets":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.contains("Piece") ? "Piece" : (availableUOMs.first ?? ""))
            case "mcb & db", "mcb", "db":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.contains("Piece") ? "Piece" : (availableUOMs.first ?? ""))
            case "lighting":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.contains("Piece") ? "Piece" : (availableUOMs.first ?? ""))
            case "conduits & accessories", "conduits", "accessories":
                return availableUOMs.contains("m") ? "m" : (availableUOMs.contains("Rft") ? "Rft" : (availableUOMs.first ?? ""))
            default:
                return availableUOMs.first ?? ""
            }
            
        case "Plumbing":
            switch item.lowercased() {
            case "pipes", "cpvc pipes", "pvc pipes":
                return availableUOMs.contains("m") ? "m" : (availableUOMs.contains("Rft") ? "Rft" : (availableUOMs.first ?? ""))
            case "fittings":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.contains("Piece") ? "Piece" : (availableUOMs.first ?? ""))
            case "fixtures":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.contains("Set") ? "Set" : (availableUOMs.first ?? ""))
            case "valves":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.contains("Piece") ? "Piece" : (availableUOMs.first ?? ""))
            case "water tanks":
                return availableUOMs.contains("Nos") ? "Nos" : (availableUOMs.contains("Unit") ? "Unit" : (availableUOMs.first ?? ""))
            default:
                return availableUOMs.first ?? ""
            }
            
        case "Tiles", "Tiles & Granite":
            // For Tiles, use Tiles & Granite UOM options
            let tilesUOMs = DepartmentItemData.uomOptions(for: "Tiles & Granite")
            return tilesUOMs.contains("Sqft") ? "Sqft" : (tilesUOMs.contains("Sqmt") ? "Sqmt" : (tilesUOMs.first ?? ""))
            
        case "Paint", "Painting":
            // For Paint, use Painting UOM options
            let paintUOMs = DepartmentItemData.uomOptions(for: "Painting")
            return paintUOMs.contains("Litre") ? "Litre" : (paintUOMs.first ?? "")
            
        default:
            // Return first available UOM for the itemType
            return availableUOMs.first ?? ""
        }
    }
    
    // MARK: - Convert Dictionary to ProjectTemplate
    static func convertToProjectTemplate(templateDict: [String: Any]) -> ProjectTemplate? {
        guard let id = templateDict["id"] as? String,
              let name = templateDict["title"] as? String,
              let description = templateDict["description"] as? String,
              let icon = templateDict["icon"] as? String,
              let phasesArray = templateDict["phases"] as? [[String: Any]] else {
            print("⚠️ TemplateData: Failed to convert template - missing required fields")
            return nil
        }
        
        let location = templateDict["location"] as? String ?? ""
        let currency = templateDict["currency"] as? String ?? "INR"
        let allowTemplateOverrides = templateDict["allowTemplateOverrides"] as? Bool ?? false
        
        var convertedPhases: [ProjectTemplate.TemplatePhase] = []
        
        for (phaseIndex, phaseDict) in phasesArray.enumerated() {
            guard let phaseName = phaseDict["phaseName"] as? String,
                  let startDateDays = phaseDict["startDateDays"] as? Int,
                  let endDateDays = phaseDict["endDateDays"] as? Int,
                  let departmentsArray = phaseDict["departments"] as? [[String: Any]] else {
                print("⚠️ TemplateData: Failed to convert phase \(phaseIndex) - missing required fields")
                continue
            }
            
            let startDate = Calendar.current.date(byAdding: .day, value: startDateDays, to: Date()) ?? Date()
            let endDate = Calendar.current.date(byAdding: .day, value: endDateDays, to: Date()) ?? Date()
            
            var convertedDepartments: [ProjectTemplate.TemplateDepartment] = []
            
            for (deptIndex, deptDict) in departmentsArray.enumerated() {
                guard let deptName = deptDict["name"] as? String,
                      let contractorModeStr = deptDict["contractorMode"] as? String,
                      let lineItemsArray = deptDict["lineItems"] as? [[String: Any]] else {
                    print("⚠️ TemplateData: Failed to convert department \(deptIndex) in phase \(phaseIndex) - missing required fields")
                    continue
                }
                
                let contractorMode: ContractorMode = contractorModeStr == "Turnkey" ? .turnkey : .labourOnly
                
                var convertedLineItems: [ProjectTemplate.TemplateLineItem] = []
                
                for (itemIndex, lineItemDict) in lineItemsArray.enumerated() {
                    guard let itemType = lineItemDict["itemType"] as? String,
                          let item = lineItemDict["item"] as? String,
                          let spec = lineItemDict["spec"] as? String,
                          let quantity = lineItemDict["quantity"] as? String,
                          let unitPrice = lineItemDict["unitPrice"] as? String else {
                        print("⚠️ TemplateData: Failed to convert line item \(itemIndex) in department \(deptIndex) - missing required fields")
                        continue
                    }
                    
                    // Get UOM from dictionary, or auto-populate based on itemType and item
                    var uom = lineItemDict["uom"] as? String ?? ""
                    if uom.isEmpty {
                        uom = getDefaultUOM(itemType: itemType, item: item, spec: spec)
                        if !uom.isEmpty {
                            print("      📏 Auto-populated UOM '\(uom)' for \(itemType) -> \(item)")
                        }
                    }
                    
                    let templateLineItem = ProjectTemplate.TemplateLineItem(
                        itemType: itemType,
                        item: item,
                        spec: spec,
                        quantity: quantity,
                        uom: uom,
                        unitPrice: unitPrice
                    )
                    convertedLineItems.append(templateLineItem)
                }
                
                let templateDepartment = ProjectTemplate.TemplateDepartment(
                    name: deptName,
                    contractorMode: contractorMode,
                    lineItems: convertedLineItems
                )
                convertedDepartments.append(templateDepartment)
            }
            
            let templatePhase = ProjectTemplate.TemplatePhase(
                phaseName: phaseName,
                startDate: startDate,
                endDate: endDate,
                departments: convertedDepartments
            )
            convertedPhases.append(templatePhase)
        }
        
        let template = ProjectTemplate(
            id: id,
            name: name,
            description: description,
            icon: icon,
            location: location,
            currency: currency,
            plannedDate: Date(),
            phases: convertedPhases,
            allowTemplateOverrides: allowTemplateOverrides
        )
        
        let totalLineItems = convertedPhases.reduce(0) { total, phase in
            total + phase.departments.reduce(0) { deptTotal, dept in
                deptTotal + dept.lineItems.count
            }
        }
        print("✅ TemplateData: Successfully converted template '\(name)' with \(convertedPhases.count) phases and \(totalLineItems) total line items")
        
        return template
    }
    
    // MARK: - Get Project Template by ID
    static func getProjectTemplate(for id: String) -> ProjectTemplate? {
        // First try to get from dictionary data
        // templateData is [String: [String: Any]], so templateData[id] returns [String: Any]?
        if let templateDict = templateData[id] {
            print("📋 TemplateData: Found template '\(id)' in dictionary, converting...")
            if let template = convertToProjectTemplate(templateDict: templateDict) {
                return template
            } else {
                print("❌ TemplateData: Failed to convert template '\(id)' from dictionary")
            }
        } else {
            print("⚠️ TemplateData: Template '\(id)' not found in dictionary")
        }
        
        print("❌ TemplateData: Template '\(id)' not found")
        return nil
    }
    
    // MARK: - Search Templates
    static func searchTemplates(query: String, businessType: String? = nil) -> [TemplateDisplayItem] {
        // First filter by businessType if provided
        let templates = businessType != nil ? getTemplatesByBusinessType(businessType) : getAllTemplates()
        
        if query.isEmpty {
            return templates
        }
        
        return templates.filter { template in
            template.title.localizedCaseInsensitiveContains(query) ||
            template.description.localizedCaseInsensitiveContains(query)
        }
    }
}
