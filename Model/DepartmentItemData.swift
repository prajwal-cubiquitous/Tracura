//
//  DepartmentItemData.swift
//  Tracura
//
//  Created by Auto on 12/29/25.
//

import Foundation
import SwiftUI

// MARK: - Contractor Mode
enum ContractorMode: String, CaseIterable, Codable {
    case labourOnly = "Labour-Only"
    case turnkey = "Turnkey"
    
    var displayName: String {
        switch self {
        case .labourOnly:
            return "Labour-Only"
        case .turnkey:
            return "Turnkey"
        }
    }
}

// MARK: - Department Line Item (UI Model)
struct DepartmentLineItem: Identifiable, Codable, Equatable {
    let id: UUID
    var itemType: String = ""
    var item: String = ""
    var spec: String = ""
    var quantity: String = ""
    var uom: String = "" // Unit of Measurement
    var unitPrice: String = ""
    
    init(id: UUID = UUID(), itemType: String = "", item: String = "", spec: String = "", quantity: String = "", uom: String = "", unitPrice: String = "") {
        self.id = id
        self.itemType = itemType
        self.item = item
        self.spec = spec
        self.quantity = quantity
        self.uom = uom
        self.unitPrice = unitPrice
    }
    
    var total: Double {
        let qty = Double(quantity.replacingOccurrences(of: ",", with: "")) ?? 0
        let price = Double(unitPrice.replacingOccurrences(of: ",", with: "")) ?? 0
        return qty * price
    }
}

// MARK: - Department Item Data (Master Data)
struct DepartmentItemData {
    // Master data structure: [ItemType: [Item: [Specs]]]
    static let itemTypes: [String: [String: [String]]] = [
        
        // MARK: - Raw Materials
        "Raw material": [
            "Steel": ["Fe500 • 6 mm", "Fe500 • 8 mm", "Fe500 • 10 mm", "Fe500 • 12 mm", "Fe500 • 16 mm", "Fe500 • 20 mm"],
            "Cement": ["OPC 43", "OPC 53", "PPC"],
            "Sand": ["M-Sand • Zone I", "M-Sand • Zone II", "River Sand (Coarse)", "River Sand (Fine)"],
            "Aggregates": ["6mm Jelly", "12mm Jelly", "20mm Jelly"],
            "Bricks": ["Clay Brick", "Solid Block", "Hollow Block", "Fly Ash Brick"],
            "Water": ["Drinking Water", "Construction Water"]
        ],

        // MARK: - Labour
        "Labour": [
            "Men": [],
            "Women": [],
            "Skilled": ["Mason", "Carpenter", "Bar Bender", "Electrician", "Plumber", "Painter"],
            "Unskilled": ["Helper"]
        ],

        // MARK: - Machines & Equipment
        "Machines & eq": [
            "JCB": ["Per-day hire", "Per-hour hire"],
            "Tractor / Trolley": ["Per-trip", "Per-day"],
            "Concrete Mixer": ["Per-day hire"],
            "Vibrator": ["Per-day hire"],
            "Lift": ["Material Lift", "Passenger Lift"],
            "Scaffolding": ["Steel Scaffolding", "Aluminium Scaffolding"],
            "Cutter": ["Marble Cutter", "Wood Cutter"]
        ],

        // MARK: - Electrical
        "Electrical": [
            "Wires & Cables": ["1.5 sq mm", "2.5 sq mm", "4 sq mm", "6 sq mm", "10 sq mm", "16 sq mm"],
            "MCB & DB": ["6A MCB", "10A MCB", "16A MCB", "20A MCB", "32A MCB", "Distribution Board"],
            "Lighting": ["LED Bulb", "LED Tube", "LED Panel", "LED Strip", "Halogen"],
            "Switches & Sockets": ["Single pole", "Double pole", "5A socket", "15A socket", "Modular switches"],
            "Conduits & Accessories": ["20mm PVC", "25mm PVC", "32mm PVC", "Elbow", "Coupler", "Bend"]
        ],

        // MARK: - Plumbing
        "Plumbing": [
            "Pipes": ["PVC • 1 inch", "PVC • 2 inch", "CPVC • 1 inch", "UPVC • 1 inch"],
            "Fittings": ["Elbow", "Tee", "Reducer", "Coupler", "GI Clamp"],
            "Valves": ["Ball Valve", "Gate Valve", "Check Valve"],
            "Water Tanks": ["500 Litre", "1000 Litre", "1500 Litre"]
        ],

        // MARK: - Flooring
        "Flooring": [
            "Tiles": ["Ceramic Tile", "Vitrified Tile", "Porcelain Tile"],
            "Marble": ["Makrana White", "Indian Marble"],
            "Granite": ["Black Granite", "Red Granite", "Grey Granite"],
            "Wooden Flooring": ["Laminate", "Engineered Wood"]
        ],

        // MARK: - Tiles Work
        "Tiles & Granite": [
            "Wall Tiles": ["Bathroom Tiles", "Kitchen Tiles"],
            "Floor Tiles": ["600x600 mm", "800x800 mm", "1200x600 mm"],
            "Granite Slabs": ["20mm", "25mm"],
            "Marble Slabs": ["Premium", "Standard"]
        ],

        // MARK: - Sanitary
        "Sanitary": [
            "WC": ["Floor Mount", "Wall Hung"],
            "Wash Basins": ["Pedestal Basin", "Table Top Basin"],
            "Showers": ["Overhead Shower", "Hand Shower"],
            "Taps": ["Wall Tap", "Pillar Tap", "Mixer Tap"]
        ],

        // MARK: - Paint & Finishing
        "Painting": [
            "Interior": ["Primer", "Putty", "Distemper", "Emulsion Paint"],
            "Exterior": ["Primer", "Texture Coat", "Weather Shield Paint"],
            "Wood Polish": ["Melamine", "PU Polish"]
        ],

        // MARK: - Carpentry & Woodwork
        "Carpentry": [
            "Plywood": ["12mm", "18mm"],
            "Laminates": ["0.8mm", "1mm"],
            "Veneer": ["Natural", "Reconstituted"],
            "Doors": ["Flush Door", "Panel Door"]
        ],

        // MARK: - Glass & Aluminium
        "Glass & Aluminium": [
            "Glass Types": ["Clear Glass", "Frosted Glass", "Toughened Glass"],
            "Aluminium Sections": ["2 Track", "3 Track", "Sliding Sections"],
            "Partitions": ["Office Partition", "Bathroom Partition"]
        ],

        // MARK: - False Ceiling
        "False Ceiling": [
            "Gypsum": ["12mm Board", "Moisture Resistant Board"],
            "POP Work": ["Design Work", "Straight Ceiling"],
            "Grid Ceiling": ["2x2 Panel", "Acoustic Tiles"]
        ],

        // MARK: - Hardware
        "Hardware": [
            "Screws": ["Wood Screw", "Machine Screw"],
            "Hinges": ["3 inch", "4 inch"],
            "Locks": ["Door Lock", "Pad Lock"],
            "Handles": ["Door Handle", "Cabinet Handle"]
        ],
        
        
        //Tools
        "Tools": [
            "Hand Tools": ["Hammer","Measuring Tape","Spirit Level","Plier","Screwdriver Set","Spanner Set","Chisel","Hand Saw"],
            "Power Tools": ["Drill Machine","Angle Grinder","Marble Cutter","Electric Screwdriver","Impact Wrench","Cut-off Machine"],
            "Safety Tools": ["Helmet","Safety Shoes","Gloves","Reflective Jacket","Safety Goggles"],
            "Masonry Tools": ["Trowel","Float","Mortar Pan","Brick Hammer","Concrete Rake","Tile Cutter (Manual)"],
            "Measurement Tools": ["Laser Distance Meter","Vernier Caliper","Square","Measuring Wheel"]
        ],


        // MARK: - Waterproofing
        "Waterproofing": [
            "Chemicals": ["Liquid Membrane", "Cementitious Coating"],
            "Sheets": ["Bitumen Sheet", "APP Membrane"],
            "Additives": ["Waterproofing Compound"]
        ]
    ]

    
    // Get all item type keys sorted
    static var itemTypeKeys: [String] {
        Array(itemTypes.keys).sorted()
    }
    
    // Get items for a specific item type
    static func items(for itemType: String) -> [String] {
        guard let items = itemTypes[itemType] else { return [] }
        return Array(items.keys).sorted()
    }
    
    // Get specs for a specific item type and item
    static func specs(for itemType: String, item: String) -> [String] {
        guard let items = itemTypes[itemType],
              let specs = items[item] else { return [] }
        return specs
    }
    

    
    // Get UOM options filtered by item type
    static func uomOptions(for itemType: String) -> [String] {
        switch itemType {

            // RAW MATERIAL
            case "Raw material":
                return ["KG", "Tonne", "m³", "Cft", "Bag", "Litre"]

            // LABOUR
            case "Labour":
                return ["Per Day", "Per Hour", "Nos", "Unit"]

            // MACHINES
            case "Machines & eq":
                return ["Per Day", "Per Hour", "Per Trip"]

            // ELECTRICAL
            case "Electrical":
                return ["m", "Rft", "Piece", "Nos", "Unit", "Roll", "Set", "Box", "Bundle", "m²", "Sqft", "Sqmt"]

            // PLUMBING
            case "Plumbing":
                return ["m", "Rft", "Piece", "Nos", "Unit", "Set", "Kg", "Litre"]

            // FLOORING
            case "Flooring":
                return ["Sqft", "Sqmt", "m²", "Piece", "Nos", "Box"]

            // TILES & GRANITE
            case "Tiles & Granite":
                return ["Sqft", "Sqmt", "m²", "Piece", "Box", "Slab"]

            // SANITARY
            case "Sanitary":
                return ["Nos", "Set", "Unit", "Piece"]

            // PAINTING
            case "Painting":
                return ["Litre", "Kg", "Sqft", "Sqmt", "m²", "Bucket"]

            // CARPENTRY (Woodwork)
            case "Carpentry":
                return ["Sheet", "Nos", "Piece", "Sqft", "Rft", "Unit"]

            // GLASS & ALUMINIUM
            case "Glass & Aluminium":
                return ["Sqft", "Sqmt", "m²", "Rft", "Piece", "Nos", "Set"]

            // FALSE CEILING
            case "False Ceiling":
                return ["Sqft", "Sqmt", "m²", "Piece", "Box"]

            // HARDWARE
            case "Hardware":
                return ["Piece", "Nos", "Set", "Box", "Packet"]

            // WATERPROOFING
            case "Waterproofing":
                return ["Litre", "Kg", "Sqft", "Sqmt", "m²", "Unit", "Set"]
            
            /// Tools
            case "Tools":
                return ["Nos", "Piece", "Set", "Unit", "Per Day", "Per Hour"]


            // DEFAULT → return ALL UOMs
            default:
                let allUOMs = Set([
                    // Raw material
                    "KG", "Tonne", "m³", "Cft", "Bag", "Litre",

                    // Labour
                    "Per Day", "Per Hour", "Nos", "Unit",

                    // Machines
                    "Per Trip",

                    // Electrical
                    "m", "Rft", "Piece", "Roll", "Set", "Box", "Bundle", "m²", "Sqft", "Sqmt",

                    // Plumbing
                    "Kg",

                    // Flooring
                    "Sheet", "Slab", "Bucket", "Packet",
                    
                    // Tools
                    "Piece", "Set", "Unit", "Nos", "Per Day", "Per Hour"
                ])
                return Array(allUOMs).sorted()
        }

    }
    
    // Get all available UOM options (for when item type is not selected)
    static var allUOMOptions: [String] {
        return uomOptions(for: "")
    }
}

