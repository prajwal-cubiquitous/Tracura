//
//  ReceiptAnalysisService.swift
//  Tracura
//
//  Created by Auto on 12/23/25.
//

import Foundation
import UIKit
import Vision

// MARK: - Detected Text Structure
struct DetectedText {
    let text: String
    let rect: CGRect
}

// MARK: - Receipt Analysis Service
class ReceiptAnalysisService {
    static let shared = ReceiptAnalysisService()
    
    private init() {}
    
    /// Analyze receipt image and extract expense fields using Vision framework
    func analyzeReceipt(image: UIImage) async throws -> ReceiptAnalysisResult {
        guard let cgImage = image.cgImage else {
            throw ReceiptAnalysisError.imageProcessingFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: ReceiptAnalysisError.visionError(error.localizedDescription))
                    return
                }
                
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let detectedTexts = observations.compactMap { obs -> DetectedText? in
                    guard let candidate = obs.topCandidates(1).first else { return nil }
                    // Convert normalized bounding box to CGRect
                    let boundingBox = obs.boundingBox
                    let rect = CGRect(
                        x: boundingBox.minX,
                        y: 1 - boundingBox.maxY, // Vision uses bottom-left origin, flip Y
                        width: boundingBox.width,
                        height: boundingBox.height
                    )
                    return DetectedText(
                        text: candidate.string,
                        rect: rect
                    )
                }
                
                let extractedFields = self.mapFields(detectedTexts)
                let result = self.parseAnalysisResult(from: extractedFields)
                continuation.resume(returning: result)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: ReceiptAnalysisError.visionError(error.localizedDescription))
            }
        }
    }
    
    /// Map detected text to form fields
    private func mapFields(_ texts: [DetectedText]) -> [String: String] {
        var output: [String: String] = [:]
        
        // First, handle special patterns like "Quantity - 5" or "UnitPrice - 20,000"
        for text in texts {
            let lowercased = text.text.lowercased()
            
            // Check for "Quantity - X" or "Qty - X" pattern
            if lowercased.contains("quantity") || lowercased.contains("qty") {
                if let quantity = extractValueAfterDash(text.text) {
                    output["quantity"] = quantity
                } else if let quantity = findValue(for: text, in: texts) {
                    output["quantity"] = quantity
                }
            }
            
            // Check for "UnitPrice - X" or "Unit Price - X" pattern
            if lowercased.contains("unitprice") || lowercased.contains("unit price") || lowercased.contains("rate") {
                if let unitPrice = extractValueAfterDash(text.text) {
                    output["unitPrice"] = unitPrice
                } else if let unitPrice = findValue(for: text, in: texts) {
                    output["unitPrice"] = unitPrice
                }
            }
        }
        
        // Map other fields using FormField aliases
        for field in fixedExpenseFields {
            // Skip if already extracted
            if output[field.key] != nil {
                continue
            }
            
            // Find label matching field aliases
            if let label = texts.first(where: { detectedText in
                let lowercased = detectedText.text.lowercased()
                return field.aliases.contains { alias in
                    lowercased.contains(alias.lowercased())
                }
            }) {
                // Try to find value next to the label
                if let value = findValue(for: label, in: texts) {
                    output[field.key] = value
                }
            }
        }
        
        return output
    }
    
    /// Extract value after dash (e.g., "Quantity - 5" -> "5")
    private func extractValueAfterDash(_ text: String) -> String? {
        // Look for patterns like "Quantity - 5" or "UnitPrice - 20,000" or "Quantity: 5"
        let patterns = [
            #"-\s*([\d,]+\.?\d*)"#,  // "Quantity - 5" or "UnitPrice - 20,000"
            #":\s*([\d,]+\.?\d*)"#     // "Quantity: 5" or "UnitPrice: 20,000"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: text) {
                let value = String(text[range])
                    .replacingOccurrences(of: "₹", with: "")
                    .replacingOccurrences(of: "$", with: "")
                    .replacingOccurrences(of: ",", with: "")
                    .trimmingCharacters(in: .whitespaces)
                if !value.isEmpty {
                    return value
                }
            }
        }
        
        // Fallback: simple dash split
        let components = text.components(separatedBy: "-")
        if components.count >= 2 {
            let value = components[1].trimmingCharacters(in: .whitespaces)
            // Remove currency symbols and clean up
            let cleaned = value
                .replacingOccurrences(of: "₹", with: "")
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespaces)
            if !cleaned.isEmpty {
                return cleaned
            }
        }
        
        return nil
    }
    
    /// Find value next to a label (to the right on same line)
    private func findValue(for label: DetectedText, in texts: [DetectedText]) -> String? {
        // Find texts that are to the right of the label and on roughly the same line
        let candidates = texts.filter { text in
            // Don't match the same text
            guard text.text != label.text else { return false }
            
            // Check if text is to the right of label (with some tolerance)
            let isToRight = text.rect.minX > label.rect.maxX - 0.1
            // Check if text is on roughly the same line (Y position similar, more tolerance)
            let isOnSameLine = abs(text.rect.midY - label.rect.midY) < 0.15
            
            // Also check if text is not too far to the right (within reasonable distance)
            let distance = text.rect.minX - label.rect.maxX
            let isNotTooFar = distance < 0.5
            
            return isToRight && isOnSameLine && isNotTooFar
        }
        
        // Return the closest one to the right
        if let closest = candidates
            .sorted(by: { $0.rect.minX < $1.rect.minX })
            .first {
            return closest.text.trimmingCharacters(in: .whitespaces)
        }
        
        return nil
    }
    
    /// Parse extracted fields into ReceiptAnalysisResult
    private func parseAnalysisResult(from fields: [String: String]) -> ReceiptAnalysisResult {
        // Parse date
        var date: Date? = nil
        if let dateString = fields["date"] {
            let formatters = [
                "dd/MM/yyyy",
                "dd-MM-yyyy",
                "yyyy-MM-dd",
                "MM/dd/yyyy",
                "dd MMM yyyy",
                "dd MMMM yyyy",
                "dd/MM/yy",
                "dd-MM-yy"
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
        if let amountString = fields["amount"] {
            let cleaned = amountString
                .replacingOccurrences(of: "₹", with: "")
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: " ", with: "")
            amount = Double(cleaned)
        }
        
        // Parse description
        let description = fields["description"] ?? ""
        
        // Parse categories (comma-separated or single)
        var categories: [String] = []
        if let categoriesString = fields["categories"] {
            categories = categoriesString
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
        
        // Parse payment mode
        var paymentMode: PaymentMode = .cash
        if let modeString = fields["modeOfPayment"] {
            let lowercased = modeString.lowercased()
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
        let itemType = fields["itemType"] ?? ""
        let item = fields["item"] ?? ""
        let brand = fields["brand"] ?? ""
        let spec = fields["spec"] ?? ""
        
        // Parse quantity - remove commas
        var quantity: String = ""
        if let quantityString = fields["quantity"] {
            quantity = quantityString
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespaces)
        }
        
        let uom = fields["uom"] ?? ""
        
        // Parse unitPrice - remove commas and currency symbols
        var unitPrice: String = ""
        if let unitPriceString = fields["unitPrice"] {
            unitPrice = unitPriceString
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: "₹", with: "")
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: " ", with: "")
                .trimmingCharacters(in: .whitespaces)
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
    case visionError(String)
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process receipt image"
        case .visionError(let message):
            return "Vision Error: \(message)"
        case .parsingFailed:
            return "Failed to parse receipt data"
        }
    }
}
