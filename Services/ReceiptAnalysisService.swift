//
//  ReceiptAnalysisService.swift
//  Tracura
//
//  Optimized for better performance and accuracy
//

import Foundation
import UIKit
import Vision

// MARK: - Detected Text Structure
struct DetectedText {
    let text: String
    let rect: CGRect
    let confidence: Float
}

// MARK: - Receipt Analysis Service
class ReceiptAnalysisService {
    static let shared = ReceiptAnalysisService()
    
    // Cache for compiled regex patterns
    private let valuePatterns: [NSRegularExpression]
    private let numberPattern: NSRegularExpression
    private let datePatterns: [DateFormatter]
    
    private init() {
        // Pre-compile regex patterns for better performance
        let patterns = [
            #"[-:]\s*([\d,]+\.?\d*)"#,
            #"[₹$]\s*([\d,]+\.?\d*)"#,
            #"\b(\d+(?:,\d{3})*(?:\.\d{2})?)\b"#
        ]
        self.valuePatterns = patterns.compactMap { try? NSRegularExpression(pattern: $0, options: []) }
        self.numberPattern = try! NSRegularExpression(pattern: #"\d+(?:,\d{3})*(?:\.\d+)?"#, options: [])
        
        // Pre-configure date formatters
        let formats = ["dd/MM/yyyy", "dd-MM-yyyy", "yyyy-MM-dd", "MM/dd/yyyy",
                       "dd MMM yyyy", "dd MMMM yyyy", "dd/MM/yy", "dd-MM-yy"]
        self.datePatterns = formats.map {
            let formatter = DateFormatter()
            formatter.dateFormat = $0
            formatter.locale = Locale(identifier: "en_US_POSIX")
            return formatter
        }
    }
    
    /// Analyze receipt image with improved performance
    func analyzeReceipt(image: UIImage) async throws -> ReceiptAnalysisResult {
        guard let cgImage = image.cgImage else {
            throw ReceiptAnalysisError.imageProcessingFailed
        }
        
        // Optimize image size for faster processing
        let optimizedImage = optimizeImageSize(cgImage)
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: ReceiptAnalysisError.visionError(error.localizedDescription))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ReceiptAnalysisError.parsingFailed)
                    return
                }
                
                // Extract text with confidence scores
                let detectedTexts = observations.compactMap { obs -> DetectedText? in
                    guard let candidate = obs.topCandidates(1).first,
                          candidate.confidence > 0.3 else { return nil }
                    
                    let boundingBox = obs.boundingBox
                    let rect = CGRect(
                        x: boundingBox.minX,
                        y: 1 - boundingBox.maxY,
                        width: boundingBox.width,
                        height: boundingBox.height
                    )
                    return DetectedText(
                        text: candidate.string,
                        rect: rect,
                        confidence: candidate.confidence
                    )
                }
                
                // Sort by Y position (top to bottom) for better context
                let sortedTexts = detectedTexts.sorted { $0.rect.minY < $1.rect.minY }
                
                let extractedFields = self.mapFieldsEfficiently(sortedTexts)
                let result = self.parseAnalysisResult(from: extractedFields)
                continuation.resume(returning: result)
            }
            
            // Optimize Vision request settings
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]
            request.minimumTextHeight = 0.02 // Skip very small text
            
            let handler = VNImageRequestHandler(cgImage: optimizedImage, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: ReceiptAnalysisError.visionError(error.localizedDescription))
                }
            }
        }
    }
    
    /// Optimize image size for faster processing
    private func optimizeImageSize(_ cgImage: CGImage) -> CGImage {
        let maxDimension: CGFloat = 2000
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        // Return original if already optimized
        guard max(width, height) > maxDimension else { return cgImage }
        
        let scale = maxDimension / max(width, height)
        let newWidth = Int(width * scale)
        let newHeight = Int(height * scale)
        
        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) else { return cgImage }
        
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        return context.makeImage() ?? cgImage
    }
    
    /// Efficiently map detected text to form fields using spatial context
    private func mapFieldsEfficiently(_ texts: [DetectedText]) -> [String: String] {
        var output: [String: String] = [:]
        var processedIndices = Set<Int>()
        
        // Build spatial index for faster lookups
        let spatialIndex = buildSpatialIndex(texts)
        
        // Process each text only once
        for (index, text) in texts.enumerated() {
            guard !processedIndices.contains(index) else { continue }
            
            let lowercased = text.text.lowercased()
            let cleanText = text.text.trimmingCharacters(in: .whitespaces)
            
            // Check for inline value patterns (e.g., "Quantity - 5")
            if let (key, value) = extractInlineKeyValue(cleanText) {
                output[key] = value
                processedIndices.insert(index)
                continue
            }
            
            // Match against field definitions
            for field in fixedExpenseFields {
                guard output[field.key] == nil else { continue }
                
                if field.aliases.contains(where: { lowercased.contains($0.lowercased()) }) {
                    // Find value using spatial index
                    if let value = findValueUsingSpatialIndex(
                        for: text,
                        in: texts,
                        spatialIndex: spatialIndex,
                        processedIndices: &processedIndices
                    ) {
                        output[field.key] = value
                        processedIndices.insert(index)
                        break
                    }
                }
            }
            
            // Smart detection for common patterns without explicit labels
            if output["amount"] == nil, let amount = extractAmount(from: cleanText) {
                output["amount"] = amount
                processedIndices.insert(index)
            }
        }
        
        return output
    }
    
    /// Build spatial index for O(1) lookup of nearby text
    private func buildSpatialIndex(_ texts: [DetectedText]) -> [Int: [Int]] {
        var index: [Int: [Int]] = [:]
        
        for (i, text) in texts.enumerated() {
            let row = Int(text.rect.midY * 100) // Discretize Y position
            index[row, default: []].append(i)
        }
        
        return index
    }
    
    /// Extract key-value pairs from inline text (e.g., "Quantity - 5")
    private func extractInlineKeyValue(_ text: String) -> (String, String)? {
        let lowercased = text.lowercased()
        
        // Check for quantity patterns
        if lowercased.contains("quantity") || lowercased.contains("qty") {
            if let value = extractValueUsingPatterns(text) {
                return ("quantity", value)
            }
        }
        
        // Check for unit price patterns
        if lowercased.contains("unitprice") || lowercased.contains("unit price") ||
           lowercased.contains("rate") || lowercased.contains("price") {
            if let value = extractValueUsingPatterns(text) {
                return ("unitPrice", value)
            }
        }
        
        // Check for amount patterns
        if lowercased.contains("total") || lowercased.contains("amount") {
            if let value = extractValueUsingPatterns(text) {
                return ("amount", value)
            }
        }
        
        return nil
    }
    
    /// Extract numeric value using pre-compiled regex patterns
    private func extractValueUsingPatterns(_ text: String) -> String? {
        for pattern in valuePatterns {
            if let match = pattern.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: text) {
                return cleanNumericValue(String(text[range]))
            }
        }
        return nil
    }
    
    /// Clean numeric value by removing currency symbols and commas
    private func cleanNumericValue(_ value: String) -> String {
        value.replacingOccurrences(of: "[₹$,\\s]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
    
    /// Extract amount from text (smart detection)
    private func extractAmount(from text: String) -> String? {
        // Look for currency symbols followed by numbers
        if let match = numberPattern.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range, in: text) {
            let value = String(text[range])
            // Only return if it looks like a monetary amount (has decimal or is large)
            if value.contains(".") || (Double(value.replacingOccurrences(of: ",", with: "")) ?? 0) > 10 {
                return cleanNumericValue(value)
            }
        }
        return nil
    }
    
    /// Find value using spatial index for O(1) average lookup
    private func findValueUsingSpatialIndex(
        for label: DetectedText,
        in texts: [DetectedText],
        spatialIndex: [Int: [Int]],
        processedIndices: inout Set<Int>
    ) -> String? {
        let row = Int(label.rect.midY * 100)
        let searchRange = -2...2 // Check nearby rows
        
        var candidates: [(text: DetectedText, distance: CGFloat)] = []
        
        for offset in searchRange {
            guard let indices = spatialIndex[row + offset] else { continue }
            
            for index in indices {
                let text = texts[index]
                guard !processedIndices.contains(index),
                      text.text != label.text else { continue }
                
                // Check if to the right and within reasonable distance
                let isToRight = text.rect.minX > label.rect.maxX - 0.05
                let horizontalDistance = text.rect.minX - label.rect.maxX
                let isReasonablyClose = horizontalDistance < 0.6
                
                if isToRight && isReasonablyClose {
                    candidates.append((text, horizontalDistance))
                }
            }
        }
        
        // Return closest candidate
        if let closest = candidates.min(by: { $0.distance < $1.distance }) {
            return closest.text.text.trimmingCharacters(in: .whitespaces)
        }
        
        return nil
    }
    
    /// Parse extracted fields into ReceiptAnalysisResult
    private func parseAnalysisResult(from fields: [String: String]) -> ReceiptAnalysisResult {
        // Parse date using pre-configured formatters
        var date: Date? = nil
        if let dateString = fields["date"] {
            for formatter in datePatterns {
                if let parsedDate = formatter.date(from: dateString) {
                    date = parsedDate
                    break
                }
            }
        }
        
        // Parse amount
        let amount = fields["amount"].flatMap { Double(cleanNumericValue($0)) }
        
        // Parse description
        let description = fields["description"] ?? ""
        
        // Parse categories
        let categories = fields["categories"]?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty } ?? []
        
        // Parse payment mode
        let paymentMode = parsePaymentMode(fields["modeOfPayment"])
        
        // Material details
        let itemType = fields["itemType"] ?? ""
        let item = fields["item"] ?? ""
        let brand = fields["brand"] ?? ""
        let spec = fields["spec"] ?? ""
        let quantity = fields["quantity"].map { cleanNumericValue($0) } ?? ""
        let uom = fields["uom"] ?? ""
        let unitPrice = fields["unitPrice"].map { cleanNumericValue($0) } ?? ""
        
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
    
    /// Parse payment mode from string
    private func parsePaymentMode(_ modeString: String?) -> PaymentMode {
        guard let modeString = modeString else { return .cash }
        
        let lowercased = modeString.lowercased()
        switch lowercased {
        case let s where s.contains("upi") || s.contains("phonepe") || s.contains("gpay") || s.contains("paytm"):
            return .upi
        case let s where s.contains("cheque") || s.contains("check"):
            return .cheque
        case let s where s.contains("card") || s.contains("credit") || s.contains("debit"):
            return .Card
        default:
            return .cash
        }
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
