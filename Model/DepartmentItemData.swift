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
            return "Labour-Only (materials + labour)"
        case .turnkey:
            return "Turnkey (materials included)"
        }
    }
}

// MARK: - Department Line Item (UI Model)
struct DepartmentLineItem: Identifiable, Codable {
    let id: UUID
    var itemType: String = ""
    var item: String = ""
    var spec: String = ""
    var quantity: String = ""
    var unitPrice: String = ""
    
    init(id: UUID = UUID(), itemType: String = "", item: String = "", spec: String = "", quantity: String = "", unitPrice: String = "") {
        self.id = id
        self.itemType = itemType
        self.item = item
        self.spec = spec
        self.quantity = quantity
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
        "Raw material": [
            "Steel": ["Fe500 • 6 mm", "Fe500 • 8 mm", "Fe500 • 10 mm", "Fe500 • 12 mm", "Fe500 • 16 mm", "Fe500 • 20 mm"],
            "Cement": ["OPC 43", "OPC 53", "PPC"],
            "Sand": ["M-Sand • Zone I", "M-Sand • Zone II", "River Sand (Coarse)", "River Sand (Fine)"]
        ],
        "Labour": [
            "Men & Women": ["Unskilled", "Semi-skilled", "Skilled", "Mason", "Helper"]
        ],
        "Machines & eq": [
            "JCB": ["Per-day hire", "Per-hour hire"],
            "Tractor / Trolley": ["Per-trip", "Per-day"],
            "Concrete Mixer": ["Per-day hire"],
            "Vibrator": ["Per-day hire"]
        ],
        "Electrical": [
            "Wires & Cables": ["1.5 sq mm", "2.5 sq mm", "4 sq mm", "6 sq mm", "10 sq mm", "16 sq mm", "25 sq mm"],
            "Switches & Sockets": ["Single pole", "Double pole", "Triple pole", "5A socket", "15A socket", "Modular switches"],
            "MCB & DB": ["6A MCB", "10A MCB", "16A MCB", "20A MCB", "32A MCB", "Distribution Board"],
            "Lighting": ["LED Bulb", "LED Tube", "LED Panel", "LED Strip", "CFL", "Halogen"],
            "Conduits & Accessories": ["20mm PVC", "25mm PVC", "32mm PVC", "40mm PVC", "Elbow", "Coupler", "Bend"]
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
}

