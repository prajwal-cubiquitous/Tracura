//
//  ReceiptAnalysisService.swift
//  Tracura
//
//  Created by Auto on 12/23/25.
//

import Foundation
import UIKit

/// Service to analyze receipts using OpenAI Vision API
class ReceiptAnalysisService {
    static let shared = ReceiptAnalysisService()
    
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    private var apiKey: String {
        // Try to get API key from Info.plist first
        if let key = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String, !key.isEmpty {
            return key
        }
        // Fallback to environment variable (for development)
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !key.isEmpty {
            return key
        }
        // Return empty string if not configured (will cause API call to fail with clear error)
        return ""
    }
    
    private init() {}
    
    /// Analyze receipt image and extract expense fields
    func analyzeReceipt(image: UIImage) async throws -> ReceiptAnalysisResult {
        // Check if API key is configured
        guard !apiKey.isEmpty else {
            throw ReceiptAnalysisError.apiError("OpenAI API key not configured. Please add 'OpenAIAPIKey' to Info.plist or set OPENAI_API_KEY environment variable.")
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ReceiptAnalysisError.imageProcessingFailed
        }
        
        // Convert image to base64
        let base64Image = imageData.base64EncodedString()
        
        // Create the prompt based on FormField.swift
        let systemPrompt = """
        You are an expert at extracting information from receipts, invoices, and handwritten notes for construction/expense management. 
        Analyze the image carefully and extract the following fields in JSON format.
        Pay special attention to handwritten text, labels, and any numerical values.
        
        CRITICAL: Look for these specific patterns:
        - "Quantity" or "Qty" followed by a number
        - "Unit Price" or "UnitPrice" or "Rate" or "Price" followed by a number
        - "Amount" or "Total" which is the total amount
        - Any labels like "Quantity - 5" means quantity is 5
        - Any labels like "UnitPrice - 20,000" means unit price is 20000 (remove commas)
        
        Available fields to extract:
        - date: Expense date in format dd/MM/yyyy (e.g., "23/12/2025"). Extract from receipt date or bill date. If not visible, use null.
        - amount: Total amount paid (numeric value only, no currency symbols, remove commas). This is the final total amount.
        - description: Description or purpose of expense (what was purchased)
        - categories: Array of expense categories matching these options: ["Labour", "Raw Materials (cement/steel/sand/bricks)", "Ready-Mix / Precast (RMC, precast items)", "Equipment/Machinery Hire", "Tools & Consumables (bits, blades, smalls)", "Subcontractor Services", "Transport & Logistics (freight, loading)", "Site Utilities (power, water, fuel, internet)", "Safety & Compliance (PPE, audits)", "Permits & Regulatory Fees", "Testing & Quality (soil/cube tests, inspections)", "Waste & Disposal (debris, haulage)", "Temporary Works (scaffolding, shuttering/formwork)", "Finishes & Fixtures (tiles, paint, sanitary, lights)", "Repairs & Rework / Snag-fix", "Maintenance (post-handover window)", "Misc / Other (notes required)"]. Select the most appropriate category.
        - modeOfPayment: Payment mode - one of: "cash", "upi", "cheque", "card" (based on receipt payment method). Default to "cash" if not visible.
        - itemType: Sub-category - typically "Labour" or "Raw Materials" based on what was purchased
        - item: Material or item name (e.g., "Cement", "Steel", "Sand")
        - brand: Brand name if visible (e.g., "UltraTech", "TATA")
        - spec: Grade or specification (e.g., "M20", "Grade 60")
        - quantity: Quantity purchased (as string, extract the number after "Quantity" or "Qty". Remove any commas. Example: "5" or "500")
        - uom: Unit of measure (e.g., "ton", "kg", "bag", "Per Day", "unit"). If not visible, infer from context or use "unit".
        - unitPrice: Price per unit (as string, numeric value only, remove commas and currency symbols. Example: "20000" for "20,000" or "₹20,000")
        
        IMPORTANT EXTRACTION RULES:
        1. For quantity: Look for text like "Quantity - 5" or "Qty: 5" and extract "5"
        2. For unitPrice: Look for text like "UnitPrice - 20,000" or "Unit Price: 20000" and extract "20000" (remove commas)
        3. If you see "Quantity - X" extract X as quantity
        4. If you see "UnitPrice - Y" extract Y as unitPrice (remove commas)
        5. Always remove commas from numbers (e.g., "20,000" becomes "20000")
        6. Always remove currency symbols (₹, $, etc.)
        
        Return ONLY valid JSON with the extracted fields. Use null for missing fields. Be precise and extract all visible numerical values.
        """
        
        let userPrompt = """
        Extract all visible information from this receipt/image. Pay special attention to:
        1. Any text that says "Quantity" or "Qty" followed by a number
        2. Any text that says "UnitPrice" or "Unit Price" or "Rate" followed by a number
        3. Total amount if visible
        4. Any other relevant details
        
        Return as JSON with all extracted fields.
        """
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": userPrompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000
        ]
        
        // Create URL request
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ReceiptAnalysisError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ReceiptAnalysisError.apiError("Status \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ReceiptAnalysisError.parsingFailed
        }
        
        // Extract JSON from response (may be wrapped in markdown code blocks)
        let jsonString = extractJSON(from: content)
        
        guard let jsonData = jsonString.data(using: .utf8),
              let extractedData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw ReceiptAnalysisError.parsingFailed
        }
        
        // Parse into ReceiptAnalysisResult
        return try parseAnalysisResult(from: extractedData)
    }
    
    /// Extract JSON string from response (handles markdown code blocks)
    private func extractJSON(from content: String) -> String {
        // Remove markdown code blocks if present
        var jsonString = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if jsonString.hasPrefix("```json") {
            jsonString = String(jsonString.dropFirst(7))
        } else if jsonString.hasPrefix("```") {
            jsonString = String(jsonString.dropFirst(3))
        }
        
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        
        return jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Parse extracted data into ReceiptAnalysisResult
    private func parseAnalysisResult(from data: [String: Any]) throws -> ReceiptAnalysisResult {
        // Parse date - try multiple formats
        var date: Date? = nil
        if let dateString = data["date"] as? String {
            let formatters = [
                "dd/MM/yyyy",
                "dd-MM-yyyy",
                "yyyy-MM-dd",
                "MM/dd/yyyy",
                "dd MMM yyyy",
                "dd MMMM yyyy"
            ]
            
            for format in formatters {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                if let parsedDate = formatter.date(from: dateString) {
                    date = parsedDate
                    break
                }
            }
        }
        
        // Parse amount
        var amount: Double? = nil
        if let amountValue = data["amount"] {
            if let amountDouble = amountValue as? Double {
                amount = amountDouble
            } else if let amountString = amountValue as? String {
                // Remove currency symbols and commas
                let cleaned = amountString
                    .replacingOccurrences(of: "₹", with: "")
                    .replacingOccurrences(of: ",", with: "")
                    .replacingOccurrences(of: " ", with: "")
                amount = Double(cleaned)
            }
        }
        
        // Parse description
        let description = data["description"] as? String ?? ""
        
        // Parse categories
        var categories: [String] = []
        if let categoriesArray = data["categories"] as? [String] {
            categories = categoriesArray
        } else if let categoryString = data["categories"] as? String {
            categories = [categoryString]
        }
        
        // Parse payment mode
        var paymentMode: PaymentMode = .cash
        if let modeString = data["modeOfPayment"] as? String {
            let lowercased = modeString.lowercased()
            // Map common payment mode strings to PaymentMode enum
            switch lowercased {
            case "cash", "by cash":
                paymentMode = .cash
            case "upi", "by upi", "phonepe", "gpay", "paytm":
                paymentMode = .upi
            case "cheque", "by cheque", "check":
                paymentMode = .cheque
            case "card", "by card", "credit card", "debit card":
                paymentMode = .Card
            default:
                paymentMode = .cash
            }
        }
        
        // Parse material details
        let itemType = data["itemType"] as? String ?? ""
        let item = data["item"] as? String ?? ""
        let brand = data["brand"] as? String ?? ""
        let spec = data["spec"] as? String ?? ""
        
        // Parse quantity - handle both string and number, remove commas
        var quantity: String = ""
        if let quantityValue = data["quantity"] {
            if let quantityString = quantityValue as? String {
                quantity = quantityString.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
            } else if let quantityNumber = quantityValue as? NSNumber {
                quantity = quantityNumber.stringValue
            } else if let quantityDouble = quantityValue as? Double {
                quantity = String(format: "%.0f", quantityDouble)
            }
        }
        
        let uom = data["uom"] as? String ?? ""
        
        // Parse unitPrice - handle both string and number, remove commas and currency symbols
        var unitPrice: String = ""
        if let unitPriceValue = data["unitPrice"] {
            if let unitPriceString = unitPriceValue as? String {
                unitPrice = unitPriceString
                    .replacingOccurrences(of: ",", with: "")
                    .replacingOccurrences(of: "₹", with: "")
                    .replacingOccurrences(of: "$", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .trimmingCharacters(in: .whitespaces)
            } else if let unitPriceNumber = unitPriceValue as? NSNumber {
                unitPrice = unitPriceNumber.stringValue
            } else if let unitPriceDouble = unitPriceValue as? Double {
                // Format without decimals if it's a whole number
                if unitPriceDouble.truncatingRemainder(dividingBy: 1) == 0 {
                    unitPrice = String(format: "%.0f", unitPriceDouble)
                } else {
                    unitPrice = String(unitPriceDouble)
                }
            }
        }
        
        return ReceiptAnalysisResult(
            date: date,
            amount: amount,
            description: description,
            categories: categories,
            paymentMode: paymentMode,
            itemType: itemType,
            item: item,
            brand: brand,
            spec: spec,
            quantity: quantity,
            uom: uom,
            unitPrice: unitPrice
        )
    }
}

// MARK: - Receipt Analysis Result
struct ReceiptAnalysisResult {
    let date: Date?
    let amount: Double?
    let description: String
    let categories: [String]
    let paymentMode: PaymentMode
    let itemType: String
    let item: String
    let brand: String
    let spec: String
    let quantity: String
    let uom: String
    let unitPrice: String
}

// MARK: - Receipt Analysis Errors
enum ReceiptAnalysisError: LocalizedError {
    case imageProcessingFailed
    case invalidResponse
    case apiError(String)
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process receipt image"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .parsingFailed:
            return "Failed to parse receipt data"
        }
    }
}

