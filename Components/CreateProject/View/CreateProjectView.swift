//
//  CreateProjectView.swift
//  AVREntertainment
//
//  Created by Prajwal S S Reddy on 6/25/25.
//

// CreateProjectView.swift

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import AVFoundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Note: DepartmentItemData, DepartmentLineItem, and ContractorMode are defined in Model/DepartmentItemData.swift

// MARK: - Line Item Row View
struct LineItemRowView: View {
    @Binding var lineItem: DepartmentLineItem
    let onDelete: () -> Void
    let canDelete: Bool
    let contractorMode: ContractorMode
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
            // First Line: Edit Icon + Item Details
            HStack(spacing: DesignSystem.Spacing.small) {
                // Line Item Icon - Compact
            Button(action: {
                HapticManager.selection()
                onEdit()
            }) {
                    Image(systemName: "square.fill.text.grid.1x2")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                    
                // Item Details - Full width with truncation (ensures at least 10 chars visible per field)
                HStack(spacing: 4) {
                        if !lineItem.itemType.isEmpty {
                            Text(lineItem.itemType)
                            .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        } else {
                            Text("Line Item")
                            .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        if !lineItem.item.isEmpty {
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.4))
                                Text(lineItem.item)
                            .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                    }
                    
                                if !lineItem.spec.isEmpty {
                                    Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.4))
                                    Text(lineItem.spec)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.8))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Second Line: Quantity/Unit Price Info + Budget Button + Delete Button
            HStack(spacing: DesignSystem.Spacing.small) {
                // Quantity/Unit Price Info - Tiny letters on the left
                if !lineItem.quantity.isEmpty || !lineItem.unitPrice.isEmpty {
                    let isLabour = lineItem.itemType.lowercased() == "labour"
                    let quantityLabel = isLabour ? "Members" : "Qty"
                    let quantityValue = lineItem.quantity.isEmpty ? "0" : lineItem.quantity
                    
                    // Format unit price from string to currency
                    let unitPriceFormatted: String = {
                        if lineItem.unitPrice.isEmpty {
                            return "₹0.00"
                        }
                        let cleaned = lineItem.unitPrice.replacingOccurrences(of: ",", with: "")
                        if let price = Double(cleaned) {
                            return price.formattedCurrency
                        }
                        return lineItem.unitPrice
                    }()
                    
                    HStack(spacing: 3) {
                        Text("\(quantityLabel): \(quantityValue)")
                            .font(.system(size: 9, weight: .regular))
                            .foregroundColor(.secondary.opacity(0.7))
                        
                        if !lineItem.unitPrice.isEmpty {
                            Text("•")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Text("Unit: \(unitPriceFormatted)")
                                .font(.system(size: 9, weight: .regular))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }
                    
                    Spacer()
                    
                // Budget Button - Styled as button
                Button(action: {
                    HapticManager.selection()
                    onEdit()
                }) {
                    Text(lineItem.total.formattedCurrency)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(6)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .buttonStyle(.plain)
                    
                // Delete Button - Compact
                    if canDelete {
                        Button(action: {
                            HapticManager.selection()
                            onDelete()
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.white)
                            .font(.system(size: 10, weight: .semibold))
                            .frame(width: 24, height: 24)
                            .background(Color.red)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.small)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Line Item Edit Sheet
struct LineItemEditSheet: View {
    @Binding var lineItem: DepartmentLineItem
    let contractorMode: ContractorMode
    let isNewItem: Bool
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var editedItem: DepartmentLineItem
    @State private var quantityText: String = ""
    @State private var unitPriceText: String = ""
    @State private var uomError: String?
    @FocusState private var focusedField: Field?
    
    private enum Field { case quantity, unitPrice }
    
    init(lineItem: Binding<DepartmentLineItem>, contractorMode: ContractorMode, isNewItem: Bool, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._lineItem = lineItem
        self.contractorMode = contractorMode
        self.isNewItem = isNewItem
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedItem = State(initialValue: lineItem.wrappedValue)
    }
    
    // Filter item types based on contractor mode
    private var availableItemTypes: [String] {
        if contractorMode == .labourOnly {
            return ["Labour"]
        } else {
            return DepartmentItemData.itemTypeKeys
        }
    }
    
    // Get filtered UOM options based on selected item type
    private var availableUOMs: [String] {
        if editedItem.itemType.isEmpty {
            return DepartmentItemData.allUOMOptions
        }
        return DepartmentItemData.uomOptions(for: editedItem.itemType)
    }
    
    private var isFormValid: Bool {
        !editedItem.itemType.isEmpty &&
        !editedItem.item.isEmpty &&
        (editedItem.itemType == "Labour" || !editedItem.spec.isEmpty) &&
        !editedItem.quantity.trimmingCharacters(in: .whitespaces).isEmpty &&
        !editedItem.uom.trimmingCharacters(in: .whitespaces).isEmpty &&
        !editedItem.unitPrice.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func removeFormatting(from value: String) -> String {
        return value.replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
    private func formatAmountInput(_ input: String) -> String {
        let cleaned = removeFormatting(from: input)
        guard !cleaned.isEmpty else { return "" }
        guard let number = Double(cleaned) else { return cleaned }
        return formatIndianNumber(number)
    }
    
    private func formatIndianNumber(_ number: Double) -> String {
        let integerPart = Int(number)
        let decimalPart = number - Double(integerPart)
        let integerString = String(integerPart)
        let digits = Array(integerString)
        let count = digits.count
        
        if count < 4 {
            var result = integerString
            if decimalPart > 0.0001 {
                let decimalString = String(format: "%.2f", decimalPart)
                if let dotIndex = decimalString.firstIndex(of: ".") {
                    let afterDot = String(decimalString[decimalString.index(after: dotIndex)...])
                    result += "." + afterDot
                }
            }
            return result
        }
        
        var groups: [String] = []
        var remainingDigits = digits
        
        if remainingDigits.count >= 3 {
            let lastThree = String(remainingDigits.suffix(3))
            groups.append(lastThree)
            remainingDigits = Array(remainingDigits.dropLast(3))
        } else {
            groups.append(String(remainingDigits))
            remainingDigits = []
        }
        
        while remainingDigits.count >= 2 {
            let lastTwo = String(remainingDigits.suffix(2))
            groups.insert(lastTwo, at: 0)
            remainingDigits = Array(remainingDigits.dropLast(2))
        }
        
        if remainingDigits.count == 1 {
            groups.insert(String(remainingDigits[0]), at: 0)
        }
        
        let result = groups.joined(separator: ",")
        var finalResult = result
        if decimalPart > 0.0001 {
            let decimalString = String(format: "%.2f", decimalPart)
            if let dotIndex = decimalString.firstIndex(of: ".") {
                let afterDot = String(decimalString[decimalString.index(after: dotIndex)...])
                finalResult += "." + afterDot
            }
        }
        
        return finalResult
    }
    
    private func validateUOM() {
        if editedItem.itemType.isEmpty {
            uomError = nil
        } else if editedItem.uom.trimmingCharacters(in: .whitespaces).isEmpty {
            uomError = "UOM is required"
        } else {
            uomError = nil
        }
    }
    
    private func save() {
        validateUOM()
        guard isFormValid && uomError == nil else { return }
        
        lineItem = editedItem
        onSave()
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Drag Indicator
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.secondary.opacity(0.35),
                                    Color.secondary.opacity(0.25),
                                    Color.secondary.opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 44, height: 5.5)
                        .shadow(color: Color.secondary.opacity(0.1), radius: 2, x: 0, y: 1)
                        .padding(.top, DesignSystem.Spacing.small)
                        .padding(.bottom, DesignSystem.Spacing.medium)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                        // Item Type
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                            Text("Item Type")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(availableItemTypes, id: \.self) { itemType in
                                    Button(action: {
                                        HapticManager.selection()
                                        let previousItemType = editedItem.itemType
                                        editedItem.itemType = itemType
                                        editedItem.item = ""
                                        editedItem.spec = ""
                                        
                                        if previousItemType != itemType {
                                            let newUOMs = DepartmentItemData.uomOptions(for: itemType)
                                            if !newUOMs.contains(editedItem.uom) {
                                                editedItem.uom = ""
                                            }
                                        }
                                        validateUOM()
                                    }) {
                                        HStack {
                                            Text(itemType)
                                            if editedItem.itemType == itemType {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(editedItem.itemType.isEmpty ? "Select Item Type" : editedItem.itemType)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(editedItem.itemType.isEmpty ? .secondary : .primary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.85)
                                        .truncationMode(.tail)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.secondary)
                                        .frame(width: 16)
                                }
                                .padding(.horizontal, DesignSystem.Spacing.large)
                                .padding(.vertical, DesignSystem.Spacing.medium)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(.tertiarySystemGroupedBackground),
                                            Color(.tertiarySystemGroupedBackground).opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color(.separator).opacity(0.3),
                                                    Color(.separator).opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                        
                        // Item + Spec
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                            Text(editedItem.itemType == "Labour" ? "Item" : "Item + Spec")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: DesignSystem.Spacing.small) {
                                // Item Dropdown
                                Menu {
                                    ForEach(DepartmentItemData.items(for: editedItem.itemType), id: \.self) { item in
                                        Button(action: {
                                            HapticManager.selection()
                                            editedItem.item = item
                                            if editedItem.itemType != "Labour" {
                                                editedItem.spec = ""
                                            }
                                        }) {
                                            HStack {
                                                Text(item)
                                                if editedItem.item == item {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(editedItem.item.isEmpty ? "Select Item" : editedItem.item)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(editedItem.item.isEmpty ? .secondary : .primary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.85)
                                            .truncationMode(.tail)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 16)
                                    }
                                    .padding(.horizontal, DesignSystem.Spacing.large)
                                    .padding(.vertical, DesignSystem.Spacing.medium)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(.tertiarySystemGroupedBackground),
                                                Color(.tertiarySystemGroupedBackground).opacity(0.8)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color(.separator).opacity(0.3),
                                                        Color(.separator).opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                }
                                .disabled(editedItem.itemType.isEmpty)
                                .opacity(editedItem.itemType.isEmpty ? 0.6 : 1.0)
                                
                                // Spec Dropdown (hidden for Labour)
                                if editedItem.itemType != "Labour" {
                                    Menu {
                                        ForEach(DepartmentItemData.specs(for: editedItem.itemType, item: editedItem.item), id: \.self) { spec in
                                            Button(action: {
                                                HapticManager.selection()
                                                editedItem.spec = spec
                                            }) {
                                                HStack {
                                                    Text(spec)
                                                    if editedItem.spec == spec {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(editedItem.spec.isEmpty ? "Select Spec" : editedItem.spec)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(editedItem.spec.isEmpty ? .secondary : .primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                                .truncationMode(.tail)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.secondary)
                                                .frame(width: 16)
                                        }
                                        .padding(.horizontal, DesignSystem.Spacing.large)
                                        .padding(.vertical, DesignSystem.Spacing.medium)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color(.tertiarySystemGroupedBackground),
                                                    Color(.tertiarySystemGroupedBackground).opacity(0.8)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(.separator).opacity(0.3),
                                                            Color(.separator).opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                    .disabled(editedItem.item.isEmpty)
                                    .opacity(editedItem.item.isEmpty ? 0.6 : 1.0)
                                }
                            }
                        }
                        
                        // Quantity, UOM, and Unit Price
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            // Quantity/Members and UOM in a row
                            HStack(spacing: DesignSystem.Spacing.medium) {
                                // Quantity (Members for Labour)
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                                    Text(editedItem.itemType == "Labour" ? "Members" : "Quantity")
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(.secondary)
                                    
                                    TextField("0", text: Binding(
                                        get: { quantityText.isEmpty ? editedItem.quantity : quantityText },
                                        set: { newValue in
                                            quantityText = formatAmountInput(newValue)
                                            editedItem.quantity = quantityText
                                        }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .font(DesignSystem.Typography.caption1)
                                    .multilineTextAlignment(.trailing)
                                    .focused($focusedField, equals: .quantity)
                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                                    .padding(.vertical, DesignSystem.Spacing.small)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(.tertiarySystemGroupedBackground),
                                                Color(.tertiarySystemGroupedBackground).opacity(0.8)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                focusedField == .quantity
                                                    ? LinearGradient(
                                                        colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.3)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    : LinearGradient(
                                                        colors: [
                                                            Color(.separator).opacity(0.3),
                                                            Color(.separator).opacity(0.1)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                lineWidth: focusedField == .quantity ? 2 : 1
                                            )
                                    )
                                    .onAppear {
                                        quantityText = editedItem.quantity
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                // UOM (Unit of Measurement)
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                                    Text("UOM")
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(.secondary)
                                    
                                    Menu {
                                        ForEach(availableUOMs, id: \.self) { uom in
                                            Button(action: {
                                                HapticManager.selection()
                                                editedItem.uom = uom
                                                validateUOM()
                                            }) {
                                                HStack {
                                                    Text(uom)
                                                    if editedItem.uom == uom {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(editedItem.itemType.isEmpty ? "Item Type" : (editedItem.uom.isEmpty ? "Select UOM" : editedItem.uom))
                                                .font(DesignSystem.Typography.caption1)
                                                .foregroundColor(editedItem.uom.isEmpty ? .secondary : .primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                                .truncationMode(.tail)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .frame(width: 16)
                                        }
                                        .padding(.horizontal, DesignSystem.Spacing.medium)
                                        .padding(.vertical, DesignSystem.Spacing.small)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color(.tertiarySystemGroupedBackground),
                                                    Color(.tertiarySystemGroupedBackground).opacity(0.8)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    uomError != nil
                                                        ? LinearGradient(
                                                            colors: [.red, .red.opacity(0.6)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                        : LinearGradient(
                                                            colors: [
                                                                Color(.separator).opacity(0.3),
                                                                Color(.separator).opacity(0.1)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                    lineWidth: uomError != nil ? 2 : 1
                                                )
                                        )
                                    }
                                    .disabled(editedItem.itemType.isEmpty)
                                    .opacity(editedItem.itemType.isEmpty ? 0.6 : 1.0)
                                    
                                    if let error = uomError {
                                        HStack(spacing: DesignSystem.Spacing.extraSmall) {
                                            Image(systemName: "exclamationmark.circle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.red)
                                            Text(error)
                                                .font(DesignSystem.Typography.caption2)
                                                .foregroundColor(.red)
                                        }
                                        .padding(.top, DesignSystem.Spacing.extraSmall)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // Unit Price
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                                Text(editedItem.itemType == "Labour" ? (editedItem.uom.isEmpty ? "UOM Price" : "\(editedItem.uom) Price") : "Unit Price")
                                    .font(DesignSystem.Typography.caption1)
                                    .foregroundColor(.secondary)
                                
                                TextField("0", text: Binding(
                                    get: { unitPriceText.isEmpty ? editedItem.unitPrice : unitPriceText },
                                    set: { newValue in
                                        unitPriceText = formatAmountInput(newValue)
                                        editedItem.unitPrice = unitPriceText
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                .font(DesignSystem.Typography.caption1)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .unitPrice)
                                .padding(.horizontal, DesignSystem.Spacing.medium)
                                .padding(.vertical, DesignSystem.Spacing.small)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(.tertiarySystemGroupedBackground),
                                            Color(.tertiarySystemGroupedBackground).opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            focusedField == .unitPrice
                                                ? LinearGradient(
                                                    colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                : LinearGradient(
                                                    colors: [
                                                        Color(.separator).opacity(0.3),
                                                        Color(.separator).opacity(0.1)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                            lineWidth: focusedField == .unitPrice ? 2 : 1
                                        )
                                )
                                .onAppear {
                                    unitPriceText = editedItem.unitPrice
                                }
                            }
                        }
                        
                        // Total Display
                        HStack {
                            HStack(spacing: DesignSystem.Spacing.extraSmall) {
                                Image(systemName: "sum")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, Color(red: 1.0, green: 0.75, blue: 0.0)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .symbolRenderingMode(.hierarchical)
                                Text("Total")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Text(editedItem.total.formattedCurrency)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, DesignSystem.Spacing.medium)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.08),
                                    Color.mint.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.green.opacity(0.2),
                                            Color.mint.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.large)
                    .padding(.bottom, DesignSystem.Spacing.large)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isNewItem ? "Add Line Item" : "Edit Line Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        HapticManager.selection()
                        onCancel()
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.blue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isNewItem ? "Add" : "Save") {
                        HapticManager.impact(.medium)
                        save()
                    }
                    .disabled(!isFormValid || uomError != nil)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(
                        isFormValid && uomError == nil
                            ? LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.gray.opacity(0.5),
                                    Color.gray.opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                }
            }
            .onAppear {
                quantityText = editedItem.quantity
                unitPriceText = editedItem.unitPrice
                validateUOM()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct CreateProjectView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @StateObject private var viewModel = CreateProjectViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingReviewScreen = false
    @State private var showingFileViewer = false
    @State private var showingCamera = false
    @State private var expandedPhaseIds: Set<UUID> = [] // Track which phases are expanded
    @State private var showingClearFormConfirmation = false
    @State private var showingAddDepartmentSheet = false
    @State private var selectedPhaseForDepartment: UUID? = nil
    @State private var showingAddPhaseSheet = false
    @State private var businessType: String? = nil
    @State private var availableTemplateNames: [String] = []
    @State private var isLoadingBusinessType: Bool = true
    
    let projectToEdit: Project? // Optional project for editing
    let template: ProjectTemplate? // Optional template for new project
    
    init(projectToEdit: Project? = nil, template: ProjectTemplate? = nil) {
        self.projectToEdit = projectToEdit
        self.template = template
    }
    
    let currencies = [
        ("₹ Indian Rupee", "INR"),
        ("$ US Dollar", "USD"),
        ("€ Euro", "EUR"),
        ("£ British Pound", "GBP")
    ]
    
    // MARK: - Fetch Business Type
    private func fetchBusinessType() async {
        guard projectToEdit == nil else {
            // Don't fetch business type for editing projects
            isLoadingBusinessType = false
            return
        }
        
        do {
            guard let currentUser = Auth.auth().currentUser else {
                print("⚠️ CreateProjectView: No current user found")
                await MainActor.run {
                    isLoadingBusinessType = false
                }
                return
            }
            
            var customerId: String
            
            // Determine customer ID based on authentication method
            if let phoneNumber = currentUser.phoneNumber {
                // Phone number user (OTP) - fetch ownerID from users collection
                let userDoc = try await Firestore.firestore()
                    .collection("users")
                    .document(currentUser.uid)
                    .getDocument()
                
                if let userData = userDoc.data(),
                   let ownerID = userData["ownerID"] as? String {
                    customerId = ownerID
                } else {
                    customerId = currentUser.uid
                }
            } else {
                // Email user (admin) - use UID as customer ID
                customerId = currentUser.uid
            }
            
            // Fetch customer document
            let customerDoc = try await Firestore.firestore()
                .collection("customers")
                .document(customerId)
                .getDocument()
            
            if let customerData = customerDoc.data(),
               let businessTypeValue = customerData["businessType"] as? String {
                await MainActor.run {
                    self.businessType = businessTypeValue
                    // Update available template names based on business type
                    self.availableTemplateNames = TemplateDataStore.getTemplateNamesByBusinessType(businessTypeValue)
                    print("✅ CreateProjectView: Fetched businessType: \(businessTypeValue), available templates: \(self.availableTemplateNames)")
                    isLoadingBusinessType = false
                }
            } else {
                print("⚠️ CreateProjectView: businessType not found in customer document")
                await MainActor.run {
                    isLoadingBusinessType = false
                }
            }
        } catch {
            print("❌ CreateProjectView: Error fetching businessType: \(error.localizedDescription)")
            await MainActor.run {
                isLoadingBusinessType = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    mainContent
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle(projectToEdit != nil ? "Edit Project" : "New Project")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // Hide icons when rejection reason is showing (project is rejected)
                        if !shouldShowRejectionBanner {
                            // Clear saved data button (only when saved data exists)
                            if viewModel.hasSavedLocalData {
                                Button(action: {
                                    HapticManager.selection()
                                    showingClearFormConfirmation = true
                                }) {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .foregroundColor(.orange)
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .help("Clear saved form data")
                            }
                            
                            // Save Draft button (only when there's any data)
                            if viewModel.hasAnyData {
                                Button(action: {
                                    HapticManager.selection()
                                    viewModel.saveDraft()
                                }) {
                                    if viewModel.isSavingDraft {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Label("Save Draft", systemImage: "square.and.arrow.down")
                                    }
                                }
                                .disabled(viewModel.isSavingDraft)
                            }
                        }
                    }
                }
                .task {
                    // Fetch business type and update available template names
                    await fetchBusinessType()
                }
                .onAppear {
                    viewModel.setAuthService(authService)
                    
                    // Load project for editing if provided
                    if let project = projectToEdit {
                        Task {
                            await viewModel.loadProjectForEditing(project)
                            // Expand all phases when editing
                            expandedPhaseIds = Set(viewModel.phases.map { $0.id })
                        }
                    } else if let template = template {
                        // Load template data
                        viewModel.loadTemplate(template)
                        // Expand all phases when using template
                        expandedPhaseIds = Set(viewModel.phases.map { $0.id })
                    } else {
                        // Restore expanded phases from saved state
                        if !viewModel.restoredExpandedPhaseIds.isEmpty {
                            expandedPhaseIds = viewModel.restoredExpandedPhaseIds.filter { id in
                                viewModel.phases.contains { $0.id == id }
                            }
                        }
                        // If no phases are expanded, expand the first one by default
                        if expandedPhaseIds.isEmpty, let firstPhaseId = viewModel.phases.first?.id {
                            expandedPhaseIds = [firstPhaseId]
                        }
                        // Load drafts
                        Task {
                            await viewModel.loadDrafts()
                        }
                    }
                }
                .onChange(of: expandedPhaseIds) { oldValue, newValue in
                    // Save expanded phase state when it changes
                    viewModel.saveFormState(expandedPhaseIds: newValue)
                }
                .onChange(of: viewModel.phases.count) { oldCount, newCount in
                    // When a new phase is added, collapse all and expand the new one
                    if newCount > oldCount, let newPhaseId = viewModel.phases.last?.id {
                        withAnimation(DesignSystem.Animation.standardSpring) {
                            expandedPhaseIds = [newPhaseId]
                        }
                    } else if newCount < oldCount {
                        // When a phase is removed, update expanded set
                        expandedPhaseIds = expandedPhaseIds.filter { id in
                            viewModel.phases.contains { $0.id == id }
                        }
                        // If no phases are expanded, expand the first one
                        if expandedPhaseIds.isEmpty, let firstPhaseId = viewModel.phases.first?.id {
                            expandedPhaseIds = [firstPhaseId]
                        }
                    }
                }
                .onChange(of: viewModel.restoredExpandedPhaseIds) { oldValue, newValue in
                    // Reset expanded phases when form is cleared (restoredExpandedPhaseIds becomes empty)
                    if newValue.isEmpty && !oldValue.isEmpty {
                        // Form was reset, expand first phase
                        if let firstPhaseId = viewModel.phases.first?.id {
                            expandedPhaseIds = [firstPhaseId]
                        } else {
                            expandedPhaseIds = []
                        }
                    }
                }
                .onChange(of: viewModel.firstInvalidFieldId) { fieldId in
                    if let fieldId = fieldId {
                        print("🔄 Attempting to scroll to field: \(fieldId)")
                        
                        // Extract phase ID from field ID (format: "phase_{uuid}_name" or "phase_{uuid}_dates", etc.)
                        if fieldId.hasPrefix("phase_") {
                            // Remove "phase_" prefix
                            let withoutPrefix = String(fieldId.dropFirst(6)) // "phase_".count = 6
                            // Find the next underscore to get the UUID
                            if let underscoreIndex = withoutPrefix.firstIndex(of: "_") {
                                let uuidString = String(withoutPrefix[..<underscoreIndex])
                                if let phaseId = UUID(uuidString: uuidString) {
                                    // Expand the phase that has the error
                                    withAnimation(DesignSystem.Animation.standardSpring) {
                                        expandedPhaseIds.insert(phaseId)
                                    }
                                }
                            }
                        }
                        
                        // Use Task to ensure it runs after view updates
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                            withAnimation(.easeInOut(duration: 0.6)) {
                                proxy.scrollTo(fieldId, anchor: .top)
                            }
                        }
                    }
                }
                .alert("Project Status", isPresented: $viewModel.showAlert) {
                    Button("OK", role: .cancel) { 
                        if viewModel.showSuccessMessage {
                            dismiss()
                        }
                    }
                } message: {
                    Text(viewModel.alertMessage)
                }
                .confirmationDialog("Clear Form", isPresented: $showingClearFormConfirmation, titleVisibility: .visible) {
                    Button("Clear Form", role: .destructive) {
                        HapticManager.impact(.medium)
                        viewModel.clearFormAndLocalStorage()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will clear all form fields and remove auto-saved data from local storage. This action cannot be undone.")
                }
                .confirmationDialog("Select Attachment", isPresented: $viewModel.showingAttachmentOptions, titleVisibility: .visible) {
                    Button("Camera") {
                        showingCamera = true
                    }
                    
                    Button("Select from Photos") {
                        viewModel.showingImagePicker = true
                    }
                    
                    Button("Select from Files") {
                        viewModel.showingDocumentPicker = true
                    }
                    
                    Button("Cancel", role: .cancel) { }
                }
                .sheet(isPresented: $viewModel.showingImagePicker) {
                    ProjectImagePicker(selectedImage: Binding(
                        get: { nil },
                        set: { image in
                            viewModel.handleImageSelection(image)
                        }
                    ))
                }
                .sheet(isPresented: $showingCamera) {
                    ProjectCameraPicker(
                        selectedImage: Binding(
                            get: { nil },
                            set: { image in
                                viewModel.handleImageSelection(image)
                            }
                        ),
                        onDismiss: {
                            showingCamera = false
                        }
                    )
                }
                .sheet(isPresented: $viewModel.showingDocumentPicker) {
                    ProjectDocumentPicker(
                        allowedTypes: [.pdf, .image],
                        onDocumentPicked: viewModel.handleDocumentSelection
                    )
                }
                .sheet(isPresented: $showingFileViewer) {
                    if let urlString = viewModel.attachmentURL,
                       let url = URL(string: urlString) {
                        FileViewerSheet(fileURL: url, fileName: viewModel.attachmentName)
                    }
                }
                .sheet(isPresented: $showingReviewScreen) {
                    NavigationView {
                        ProjectReviewScreen(
                            viewModel: viewModel,
                            onConfirm: {
                                viewModel.saveProject()
                                // Dismiss review screen after starting save
                                showingReviewScreen = false
                                // Dismiss main view after save completes (handled in alert)
                            },
                            onCancel: {
                                showingReviewScreen = false
                            },
                            onEdit: {
                                // Dismiss review screen to go back to editing
                                showingReviewScreen = false
                            }
                        )
                    }
                    .presentationDetents([.large])
                }
                .sheet(isPresented: $viewModel.showDraftList) {
                    DraftProjectListView(viewModel: viewModel)
                }
                .sheet(isPresented: $showingAddDepartmentSheet) {
                    if let phaseId = selectedPhaseForDepartment,
                       let phase = viewModel.phases.first(where: { $0.id == phaseId }) {
                        CreateProjectAddDepartmentSheet(
                            phaseId: phaseId,
                            phaseName: phase.phaseName.isEmpty ? "Phase \(phase.phaseNumber)" : phase.phaseName,
                            viewModel: viewModel,
                            onSaved: {
                                showingAddDepartmentSheet = false
                                selectedPhaseForDepartment = nil
                            }
                        )
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                    }
                }
                .sheet(isPresented: $showingAddPhaseSheet) {
                    CreateProjectAddPhaseSheet(
                        viewModel: viewModel,
                        onSaved: {
                            showingAddPhaseSheet = false
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }
    
    // MARK: - Draft Management Section
    
    @ViewBuilder
    private var draftManagementSection: some View {
        if !viewModel.drafts.isEmpty || viewModel.hasAnyData {
            // View Drafts Button (only show if drafts exist)
            if !viewModel.drafts.isEmpty {
                Button(action: {
                    HapticManager.selection()
                    viewModel.showDraftList = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("View Projects in Draft")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.blue.opacity(0.6))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.08))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 0.5)
                            }
                    }
                    .padding(.horizontal, 14)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Section Views
    
    private var projectDetailsSection: some View {
        Section {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Template description
                Text("Standard template for residential building construction with common phases and departments")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DesignSystem.Spacing.extraSmall)
                    .padding(.bottom, DesignSystem.Spacing.small)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Project Name")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter project name", text: $viewModel.projectName)
                        .font(DesignSystem.Typography.body)
                        .fieldStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.projectNameError != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    if let error = viewModel.projectNameError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectName")
                
                // Description
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Description")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $viewModel.projectDescription)
                        .frame(height: 100)
                        .font(DesignSystem.Typography.body)
                        .padding(DesignSystem.Spacing.small)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(DesignSystem.CornerRadius.field)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.projectDescriptionError != nil ? Color.red : Color(.separator), lineWidth: viewModel.projectDescriptionError != nil ? 1 : 0.5)
                        )
                    
                    if let error = viewModel.projectDescriptionError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectDescription")
                
                // Client
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Client")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter client name", text: $viewModel.client)
                        .font(DesignSystem.Typography.body)
                        .fieldStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.clientError != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    if let error = viewModel.clientError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("client")
                
                // Location
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Location")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter location", text: $viewModel.location)
                        .font(DesignSystem.Typography.body)
                        .fieldStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.locationError != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    if let error = viewModel.locationError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("location")
                
                // Planned Date
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Planned Date")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        DatePicker("Select planned start date", selection: $viewModel.plannedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.small)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.field)
                    
                    Text("Project will be in LOCKED status until this date, then automatically become ACTIVE")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .id("plannedDate")
                
                // Currency Picker
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Currency")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Currency", selection: $viewModel.currency) {
                        ForEach(currencies, id: \.1) { currency in
                            Text(currency.0).tag(currency.1)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.small)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.field)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Description")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $viewModel.projectDescription)
                        .frame(height: 100)
                        .font(DesignSystem.Typography.body)
                        .padding(DesignSystem.Spacing.small)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(DesignSystem.CornerRadius.field)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.projectDescriptionError != nil ? Color.red : Color(.separator), lineWidth: viewModel.projectDescriptionError != nil ? 1 : 0.5)
                        )
                    
                    if let error = viewModel.projectDescriptionError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectDescription")
            }
            .padding(.vertical, DesignSystem.Spacing.small)
        } header: {
            SectionHeaderLabel(title: "Project Details", icon: "building.2.crop.circle")
        }
    }
    
    private var phasesSection: some View {
        Section {
            VStack(spacing: DesignSystem.Spacing.large) {
                // Use the phase ID for stable identification
                ForEach(viewModel.phases) { phase in
                    PhaseCardView(
                        phase: phaseBinding(for: phase.id),
                        phaseNumber: phase.phaseNumber,
                        totalPhases: viewModel.phases.count,
                        isExpanded: expandedPhaseIds.contains(phase.id),
                        canDelete: viewModel.phases.count > 1,
                        viewModel: viewModel,
                        onToggleExpand: {
                            withAnimation(DesignSystem.Animation.standardSpring) {
                                if expandedPhaseIds.contains(phase.id) {
                                    expandedPhaseIds.remove(phase.id)
                                } else {
                                    expandedPhaseIds.insert(phase.id)
                                }
                            }
                        },
                        onDelete: {
                            HapticManager.selection()
                            viewModel.removePhaseById(phase.id)
                        },
                        onAddDepartment: {
                            selectedPhaseForDepartment = phase.id
                            showingAddDepartmentSheet = true
                        }
                    )
                    .id(phase.id) // Critical: Tell SwiftUI to track by ID
                }
                
                // Add Phase Button
                Button(action: {
                    HapticManager.selection()
                    showingAddPhaseSheet = true
                }) {
                    Label("Add Phase", systemImage: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                }
                .secondaryButton()
                .padding(.top, DesignSystem.Spacing.small)
            }
            .padding(.vertical, DesignSystem.Spacing.small)
        } header: {
            SectionHeaderLabel(title: "Project Phases", icon: "square.3.layers.3d")
        } footer: {
            budgetFooterView
        }
    }
    
    private func phaseBinding(for id: UUID) -> Binding<PhaseItem> {
        Binding(
            get: {
                viewModel.phases.first(where: { $0.id == id }) ?? PhaseItem(phaseNumber: 1)
            },
            set: { newValue in
                if let index = viewModel.phases.firstIndex(where: { $0.id == id }) {
                    viewModel.phases[index] = newValue
                }
            }
        )
    }

    
    // Add this helper method to CreateProjectView
    private func binding(for phaseId: UUID) -> Binding<PhaseItem> {
        guard let index = viewModel.phases.firstIndex(where: { $0.id == phaseId }) else {
            fatalError("Phase not found")
        }
        return $viewModel.phases[index]
    }

    // MARK: - Project Team & Managers Section
    private var projectTeamSection: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Manager (Approver) - single selection only
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Manager (Approver)").font(.caption).foregroundColor(.secondary)
                    SingleSelectionPicker(
                        selectedUser: $viewModel.selectedProjectManager,
                        users: viewModel.allApprovers.filter { $0.isActive },
                        placeholder: "Select project manager"
                    )
                    
                    if let error = viewModel.projectManagersError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectManagers")

                // Team members
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Team Members").font(.caption).foregroundColor(.secondary)
                    SearchableDropdownView(
                        title: "Search name or phone number...",
                        searchText: $viewModel.projectTeamMemberSearchText,
                        items: viewModel.filteredProjectTeamMembers(),
                        itemContent: { user in
                            TruncatedTextWithTooltip(
                                "\(user.name) - \(user.phoneNumber)",
                                font: .body,
                                foregroundColor: .primary,
                                lineLimit: 1
                            )
                        },
                        onSelect: { member in
                            viewModel.selectedProjectTeamMembers.insert(member)
                            viewModel.projectTeamMemberSearchText = ""
                        }
                    )
                    if !viewModel.selectedProjectTeamMembers.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { ForEach(Array(viewModel.selectedProjectTeamMembers)) { member in
                                TagView(user: member, onRemove: { viewModel.selectedProjectTeamMembers.remove(member) })
                            } }
                            .padding(.top, 5)
                        }
                    }
                    
                    if let error = viewModel.projectTeamMembersError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectTeamMembers")
            }
            .padding(.vertical, DesignSystem.Spacing.small)
        } header: {
            SectionHeaderLabel(title: "Project Team", icon: "person.3.fill")
        }
    }
    
    
    private var submitSection: some View {
        Section {
            submitButton
                .padding(.vertical, DesignSystem.Spacing.small)
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // MARK: - Rejection Reason Banner (if project is DECLINED)
            if shouldShowRejectionBanner {
                rejectionReasonBanner(reason: rejectionReasonText)
            }
            
            // MARK: - Draft Management Section
            draftManagementSection
            
            // MARK: - Project Type Dropdown (only for new projects)
            if projectToEdit == nil && !availableTemplateNames.isEmpty {
                HStack(spacing: 12) {
                    
                    
                    Spacer()
                    
                    Menu {
                        ForEach(availableTemplateNames, id: \.self) { templateName in
                            Button(action: {
                                HapticManager.selection()
                                viewModel.projectType = templateName
                            }) {
                                HStack {
                                    Text(templateName)
                                        .font(.system(size: 15, weight: .medium))
                                    Spacer()
                                    if viewModel.projectType == templateName {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "slider.horizontal.2.square.on.square")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(viewModel.projectType != nil ? .blue : .secondary)
                            
                            Text(viewModel.projectType ?? "Select Type")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(viewModel.projectType != nil ? .primary : .secondary)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                           Group {
                               LinearGradient(
                                   colors: [
                                       Color.blue.opacity(0.15),
                                       Color.purple.opacity(0.15)
                                   ],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing
                               )
                           }
                       )
                       .clipShape(RoundedRectangle(cornerRadius: 14))                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.top, DesignSystem.Spacing.small)
            }
            
            // MARK: - Project Information
            projectDetailsSectionScrollView
            
            // MARK: - Phases Section
            phasesSectionScrollView
            
            // MARK: - Project Team Section
            projectTeamSectionScrollView
            
            // MARK: - Attachment Section
//            attachmentSectionScrollView
            
            // MARK: - Submit Action
            submitSectionScrollView
        }
        .padding(.horizontal, DesignSystem.Spacing.extraSmall)
        .padding(.vertical, DesignSystem.Spacing.small)
    }
    
    // MARK: - Rejection Banner Helpers
    private var shouldShowRejectionBanner: Bool {
        guard let project = projectToEdit,
              project.statusType == .DECLINED,
              let reason = project.rejectionReason,
              !reason.isEmpty else {
            return false
        }
        return true
    }
    
    private var rejectionReasonText: String {
        projectToEdit?.rejectionReason ?? ""
    }
    
    // MARK: - Rejection Reason Banner
    private func rejectionReasonBanner(reason: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(.red)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                Text("Rejection Reason")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                
                Text(reason)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(Color.red.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - ScrollView Compatible Sections
    
    private var projectDetailsSectionScrollView: some View {
        FormSectionView(header: SectionHeaderLabel(title: "Project Details", icon: "building.2.crop.circle")) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                // Template description
                Text("Standard template for residential building construction with common phases and departments")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DesignSystem.Spacing.small)
                    .padding(.bottom, DesignSystem.Spacing.extraSmall)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Project Name")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        TextField("Enter project name", text: $viewModel.projectName)
                            .font(DesignSystem.Typography.body)
                            .fieldStyle()
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                    .stroke(viewModel.projectNameError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .onChange(of: viewModel.projectName) { oldValue, newValue in
                                // Debounced check for duplicate project names
                                viewModel.debouncedCheckProjectName()
                            }
                        
                        // Loading indicator while checking
                        if viewModel.isCheckingProjectName {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.leading, 8)
                        }
                    }
                    
                    if let error = viewModel.projectNameError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectName")
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                
                Divider()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Description")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $viewModel.projectDescription)
                        .frame(height: 100)
                        .font(DesignSystem.Typography.body)
                        .padding(DesignSystem.Spacing.small)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(DesignSystem.CornerRadius.field)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.projectDescriptionError != nil ? Color.red : Color(.separator), lineWidth: viewModel.projectDescriptionError != nil ? 1 : 0.5)
                        )
                    
                    if let error = viewModel.projectDescriptionError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectDescription")
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                
                Divider()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Client")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter client name", text: $viewModel.client)
                        .font(DesignSystem.Typography.body)
                        .fieldStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.clientError != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    if let error = viewModel.clientError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("client")
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                
                Divider()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Location")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter location", text: $viewModel.location)
                        .font(DesignSystem.Typography.body)
                        .fieldStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.field)
                                .stroke(viewModel.locationError != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
                    
                    if let error = viewModel.locationError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("location")
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                
                Divider()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Planned Start Date")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        DatePicker("Select planned start date", selection: $viewModel.plannedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.small)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.field)
                    
                    Text("Project will be in LOCKED status until this date, then automatically become ACTIVE")
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .id("plannedDate")
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                
                Divider()
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Currency")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Currency", selection: $viewModel.currency) {
                        ForEach(currencies, id: \.1) { currency in
                            Text(currency.0).tag(currency.1)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.small)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.field)
                }
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
            }
        }
    }
    
    private var phasesSectionScrollView: some View {
        FormSectionView(header: SectionHeaderLabel(title: "Project Phases", icon: "square.3.layers.3d")) {
            VStack(spacing: DesignSystem.Spacing.large) {
                ForEach(viewModel.phases) { phase in
                    PhaseCardView(
                        phase: phaseBinding(for: phase.id),
                        phaseNumber: phase.phaseNumber,
                        totalPhases: viewModel.phases.count,
                        isExpanded: expandedPhaseIds.contains(phase.id),
                        canDelete: viewModel.phases.count > 1,
                        viewModel: viewModel,
                        onToggleExpand: {
                            withAnimation(DesignSystem.Animation.standardSpring) {
                                if expandedPhaseIds.contains(phase.id) {
                                    expandedPhaseIds.remove(phase.id)
                                } else {
                                    expandedPhaseIds.insert(phase.id)
                                }
                            }
                        },
                        onDelete: {
                            HapticManager.selection()
                            viewModel.removePhaseById(phase.id)
                        },
                        onAddDepartment: {
                            viewModel.addDepartment(to: phase.id)
                        }
                    )
                    .id(phase.id)
                }
                
                Button(action: {
                    HapticManager.selection()
                    withAnimation(DesignSystem.Animation.standardSpring) {
                        viewModel.addPhase()
                    }
                }) {
                    Label("Add Phase", systemImage: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(DesignSystem.Typography.callout)
                        .fontWeight(.medium)
                }
                .secondaryButton()
                .padding(.top, DesignSystem.Spacing.small)
            }
            .padding(.vertical, DesignSystem.Spacing.small)
            
            budgetFooterView
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.top, DesignSystem.Spacing.small)
        }
    }
    
    private var projectTeamSectionScrollView: some View {
        FormSectionView(header: SectionHeaderLabel(title: "Project Team", icon: "person.3.fill")) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Manager (Approver)").font(.caption).foregroundColor(.secondary)
                    SingleSelectionPicker(
                        selectedUser: $viewModel.selectedProjectManager,
                        users: viewModel.allApprovers.filter { $0.isActive },
                        placeholder: "Select project manager"
                    )
                    
                    if let error = viewModel.projectManagersError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectManagers")
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Team Members").font(.caption).foregroundColor(.secondary)
                    SearchableDropdownView(
                        title: "Search name or phone number...",
                        searchText: $viewModel.projectTeamMemberSearchText,
                        items: viewModel.filteredProjectTeamMembers(),
                        itemContent: { user in
                            TruncatedTextWithTooltip(
                                "\((user.name.count > 25 ? String(user.name.prefix(25)) + "..." : user.name)) - \(user.phoneNumber)",
                                font: .body,
                                foregroundColor: .primary,
                                lineLimit: 1
                            )
                        },
                        onSelect: { member in
                            HapticManager.selection()
                            viewModel.selectedProjectTeamMembers.insert(member)
                            viewModel.projectTeamMemberSearchText = ""
                        }
                    )
                    if !viewModel.selectedProjectTeamMembers.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { ForEach(Array(viewModel.selectedProjectTeamMembers)) { member in
                                TagView(user: member, onRemove: { viewModel.selectedProjectTeamMembers.remove(member) })
                            } }
                            .padding(.top, 5)
                        }
                    }
                    
                    if let error = viewModel.projectTeamMembersError {
                        InlineErrorMessage(message: error)
                    }
                }
                .id("projectTeamMembers")
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.small)
            }
        }
    }
    
    
//    private var attachmentSectionScrollView: some View {
//        FormSectionView(header: SectionHeaderLabel(title: "Project Attachment", icon: "paperclip")) {
//            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
//                if let attachmentName = viewModel.attachmentName {
//                    // Show attached file
//                    HStack(spacing: 12) {
//                        // File info - not clickable
//                        HStack {
//                            Image(systemName: fileIcon(for: attachmentName))
//                                .font(.title3)
//                                .foregroundColor(.blue)
//                            
//                            VStack(alignment: .leading, spacing: 4) {
//                                TruncatedTextWithTooltip(
//                                    attachmentName,
//                                    font: .subheadline,
//                                    fontWeight: .medium,
//                                    foregroundColor: .primary,
//                                    lineLimit: 1
//                                )
//                                
//                                Text("Tap preview to view")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                            
//                            Spacer()
//                        }
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(8)
//                        
//                        // Preview button - separate icon button
//                        Button(action: {
//                            HapticManager.selection()
//                            showingFileViewer = true
//                        }) {
//                            Image(systemName: "eye.fill")
//                                .font(.title3)
//                                .foregroundColor(.blue)
//                                .frame(width: 44, height: 44)
//                                .background(Color.blue.opacity(0.1))
//                                .clipShape(Circle())
//                                .contentShape(Circle())
//                        }
//                        .buttonStyle(.plain)
//                        
//                        // Remove button - separate action
//                        Button(action: {
//                            HapticManager.selection()
//                            withAnimation(.easeInOut) {
//                                viewModel.removeAttachment()
//                            }
//                        }) {
//                            Image(systemName: "trash.fill")
//                                .font(.title3)
//                                .foregroundColor(.red)
//                                .frame(width: 44, height: 44)
//                                .background(Color.red.opacity(0.1))
//                                .clipShape(Circle())
//                                .contentShape(Circle())
//                        }
//                        .buttonStyle(.plain)
//                    }
//                } else {
//                    // Add attachment button
//                    Button(action: {
//                        viewModel.showingAttachmentOptions = true
//                    }) {
//                        HStack {
//                            Image(systemName: "paperclip")
//                                .font(.title3)
//                            Text("Add Attachment")
//                                .fontWeight(.medium)
//                            Spacer()
//                        }
//                        .foregroundColor(.blue)
//                        .padding()
//                        .background(Color(UIColor.tertiarySystemFill))
//                        .cornerRadius(8)
//                    }
//                    .buttonStyle(.plain)
//                }
//                
//                // Upload progress
//                if viewModel.isUploading {
//                    VStack(spacing: 8) {
//                        ProgressView(value: viewModel.uploadProgress)
//                            .progressViewStyle(LinearProgressViewStyle())
//                        Text("Uploading... \(Int(viewModel.uploadProgress * 100))%")
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            .padding(.horizontal, DesignSystem.Spacing.medium)
//            .padding(.vertical, DesignSystem.Spacing.small)
//        }
//    }
    
    private var submitSectionScrollView: some View {
        VStack {
            submitButton
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.vertical, DesignSystem.Spacing.medium)
        }
    }
    
    // MARK: - Helper Methods
    
    private func fileIcon(for fileName: String) -> String {
        let lowercased = fileName.lowercased()
        if lowercased.hasSuffix(".pdf") {
            return "doc.fill"
        } else if lowercased.hasSuffix(".jpg") || lowercased.hasSuffix(".jpeg") {
            return "photo.fill"
        } else if lowercased.hasSuffix(".png") {
            return "photo.fill"
        } else {
            return "doc.fill"
        }
    }
    
    // MARK: - Subviews
    
    private var budgetFooterView: some View {
        HStack {
            Image(systemName: "indianrupeesign.circle.fill")
                .foregroundColor(.green)
                .font(DesignSystem.Typography.callout)
                .symbolRenderingMode(.hierarchical)
            
            Text("Total Budget:")
                .font(DesignSystem.Typography.callout)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(viewModel.totalBudgetFormatted)
                .font(DesignSystem.Typography.callout)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.top, DesignSystem.Spacing.small)
    }
    
    private var submitButton: some View {
        Button(action: {
            HapticManager.impact(.medium)
            
            // Validate and find first invalid field
            if let firstInvalidField = viewModel.validateAndFindFirstInvalidField() {
                HapticManager.notification(.error)
                // Set the invalid field ID to trigger scroll
                viewModel.firstInvalidFieldId = firstInvalidField
            } else {
                // Form is valid, proceed to review screen
                showingReviewScreen = true
            }
        }) {
            HStack {
                Label("Review Project", systemImage: "doc.text.magnifyingglass")
                    .symbolRenderingMode(.hierarchical)
            }
            .font(DesignSystem.Typography.headline)
        }
        .primaryButton()
        .disabled(viewModel.isLoading)
        .animation(DesignSystem.Animation.standardSpring, value: viewModel.isFormValid)
    }
}

// MARK: - Phase Card View

struct PhaseCardView: View {
    @Binding var phase: PhaseItem
    let phaseNumber: Int
    let totalPhases: Int
    let isExpanded: Bool
    let canDelete: Bool
    @ObservedObject var viewModel: CreateProjectViewModel
    let onToggleExpand: () -> Void
    let onDelete: () -> Void
    let onAddDepartment: () -> Void
    
    // Check if phase has required fields filled
    private var hasRequiredFields: Bool {
        !phase.phaseName.trimmingCharacters(in: .whitespaces).isEmpty &&
        phase.endDate > phase.startDate &&
        !phase.departments.isEmpty &&
        phase.departments.contains { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Phase Header - Always visible, clickable to expand/collapse
            Button(action: {
                HapticManager.selection()
                onToggleExpand()
            }) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    HStack {
                        // Phase number with total (e.g., "Phase 1/2")
                        Text("Phase \(phaseNumber)/\(totalPhases)")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
                        // Completion indicator with gradient
                        if hasRequiredFields {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .font(.system(size: 20))
                                .symbolRenderingMode(.hierarchical)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.secondary.opacity(0.5))
                                .font(.system(size: 20))
                        }
                        
                        // Expand/Collapse chevron with gradient
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolRenderingMode(.hierarchical)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                        
                        // Delete Phase Button
                        if canDelete {
                            Button(action: {
                                HapticManager.selection()
                                onDelete()
                            }) {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(width: 32, height: 32)
                                    .background(
                                        LinearGradient(
                                            colors: [.red, .red.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                                    .shadow(color: Color.red.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, DesignSystem.Spacing.small)
                        }
                    }
                    
                    // Phase Budget - Always visible in collapsed state
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "indianrupeesign.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.system(size: 14))
                            .symbolRenderingMode(.hierarchical)
                        
                        Text("Budget:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.phaseBudgetFormatted(for: phase.id))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(DesignSystem.Spacing.medium)
            
            // Expandable Content
            if isExpanded {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    // Gradient Divider
                    Divider()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.blue.opacity(0.2),
                                    Color.cyan.opacity(0.15),
                                    Color.blue.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1.5)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                    
                    // Phase Name
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Phase Name")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(.secondary)

                        TextField("Enter phase name", text: $phase.phaseName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, DesignSystem.Spacing.large)
                            .padding(.vertical, DesignSystem.Spacing.medium)
                            .background(
                                Group {
                                    if viewModel.phaseNameError(for: phase.id) != nil {
                                        // Error state - red gradient
                                        LinearGradient(
                                            colors: [.red.opacity(0.1), .red.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        // Normal state - green, blue, purple gradient
                                        LinearGradient(
                                            colors: [
                                                Color.green.opacity(0.15),
                                                Color.blue.opacity(0.15),
                                                Color.purple.opacity(0.15)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        viewModel.phaseNameError(for: phase.id) != nil
                                            ? LinearGradient(
                                                colors: [.red, .red.opacity(0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                            : LinearGradient(
                                                colors: [
                                                    Color.green.opacity(0.4),
                                                    Color.blue.opacity(0.4),
                                                    Color.purple.opacity(0.4)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                        lineWidth: viewModel.phaseNameError(for: phase.id) != nil ? 2 : 1.5
                                    )
                            )
                        
                        if let error = viewModel.phaseNameError(for: phase.id) {
                            InlineErrorMessage(message: error)
                        }
                    }
                    .id("phase_\(phase.id)_name")
                    .padding(.horizontal, DesignSystem.Spacing.medium)

                    // Timeline Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timeline")
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(.secondary)

                        // Start Date (Required)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Start Date", systemImage: "calendar.badge.plus")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            DatePicker("Select start date", selection: $phase.startDate, in: viewModel.plannedDate..., displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                        .padding(.vertical, 4)

                        // End Date (Required)
                        VStack(alignment: .leading, spacing: 8) {
                            Label("End Date", systemImage: "calendar.badge.minus")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            DatePicker("Select end date", selection: $phase.endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                        .padding(.vertical, 4)

                        // Date Validation Warnings
                        if let error = viewModel.phaseDateError(for: phase.id) {
                            InlineErrorMessage(message: error)
                        }
                        
                        if let timelineError = viewModel.phaseTimelineError(for: phase.id) {
                            InlineErrorMessage(message: timelineError)
                                .id("phase_\(phase.id)_timeline")
                        }
                    }
                    .id("phase_\(phase.id)_dates")
                    .padding(.horizontal, DesignSystem.Spacing.medium)

                    // Manager & Team note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Manager & Team for this phase are inherited from Project Team section")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)

                    // Departments
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: DesignSystem.Spacing.small) {
                            Image(systemName: "square.grid.3x3.square")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .symbolRenderingMode(.hierarchical)
                                .padding(5)
                                .background(Color.blue)
                                .clipShape(Circle())
                            Text("Departments")
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(.secondary)
                        }

                        ForEach($phase.departments) { $dept in
                            DepartmentInputRow(
                                item: $dept,
                                errorMessage: viewModel.departmentNameError(for: phase.id, departmentId: dept.id),
                                viewModel: viewModel,
                                phaseId: phase.id,
                                canDelete: phase.departments.count > 1,
                                onDelete: {
                                    viewModel.removeDepartmentById(from: phase.id, departmentId: dept.id)
                                }
                            )
                            .id("phase_\(phase.id)_dept_\(dept.id)_name")
                        }

                        Button(action: {
                            HapticManager.selection()
                            onAddDepartment()
                        }) {
                            Label("Add Department", systemImage: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(DesignSystem.Typography.caption1)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.plain)
                        
                        if let error = viewModel.phaseDepartmentsError(for: phase.id) {
                            InlineErrorMessage(message: error)
                        }
                    }
                    .id("phase_\(phase.id)_departments")
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    
//                    // Phase Budget Summary
//                    phaseBudgetView(for: phase.id)
//                        .padding(.horizontal, DesignSystem.Spacing.medium)
//                        .padding(.top, DesignSystem.Spacing.small)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, DesignSystem.Spacing.medium)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    // MARK: - Phase Budget View
    
    private func phaseBudgetView(for phaseId: UUID) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "indianrupeesign.circle.fill")
                .foregroundColor(.blue)
                .font(DesignSystem.Typography.callout)
                .symbolRenderingMode(.hierarchical)
            
            Text("Phase Budget:")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(viewModel.phaseBudgetFormatted(for: phaseId))
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, DesignSystem.Spacing.small)
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
        .padding(.top, DesignSystem.Spacing.small)
    }
}

// MARK: - Array Extension for Safe Access

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Reusable Helper Views

// Single Selection Picker for Manager Selection
struct SingleSelectionPicker: View {
    @Binding var selectedUser: User?
    let users: [User]
    let placeholder: String
    
    var body: some View {
        Menu {
            Button(action: {
                selectedUser = nil
            }) {
                HStack {
                    Text("None")
                    if selectedUser == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            ForEach(users.sorted(by: { $0.name < $1.name })) { user in
                Button(action: {
                    HapticManager.selection()
                    selectedUser = user
                }) {
                    HStack {
                        let truncatedName = user.name.count > 25 ? String(user.name.prefix(25)) + "..." : user.name
                        TruncatedTextWithTooltip(
                            "\(truncatedName) - \(user.email ?? user.phoneNumber)",
                            font: .body,
                            foregroundColor: .primary,
                            lineLimit: 1
                        )
                        if selectedUser?.phoneNumber == user.phoneNumber {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                if let selectedUser = selectedUser {
                    let truncatedName = selectedUser.name.count > 25 ? String(selectedUser.name.prefix(25)) + "..." : selectedUser.name
                    TruncatedTextWithTooltip(
                        truncatedName,
                        font: .body,
                        foregroundColor: .primary,
                        lineLimit: 1
                    )
                } else {
                    Text(placeholder)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(DesignSystem.Spacing.medium)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(DesignSystem.CornerRadius.field)
        }
    }
}

struct SearchableDropdownView<Content: View>: View {
    let title: String
    @Binding var searchText: String
    let items: [User]
    let itemContent: (User) -> Content
    let onSelect: (User) -> Void
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(title, text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isSearchFocused)
                .overlay(alignment: .trailing) {
                    if !searchText.isEmpty {
                        Button(action: { 
                            searchText = ""
                            isSearchFocused = true
                        }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }.padding(.trailing, 8)
                    }
                }
                .onTapGesture {
                    isSearchFocused = true
                }
            
            // Show dropdown when focused or when there's search text
            if !items.isEmpty && (isSearchFocused || !searchText.isEmpty) {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(items) { item in
                            Button(action: { 
                                HapticManager.selection()
                                onSelect(item)
                                isSearchFocused = false
                            }) {
                                HStack {
                                    itemContent(item)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 12)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(Color.clear)
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(1000)
            }
        }
    }
}

struct TagView: View {
    let user: User
    let onRemove: () -> Void
    
    private var truncatedName: String {
        user.name.count > 25 ? String(user.name.prefix(25)) + "..." : user.name
    }
    
    var body: some View {
        HStack(spacing: 4) {
            TruncatedTextWithTooltip(
                truncatedName,
                font: .caption,
                foregroundColor: .primary,
                lineLimit: 1
            )
            Button(action: {
                HapticManager.selection()
                onRemove()
            }) {
                Image(systemName: "xmark")
                    .font(.caption).foregroundColor(.primary)
                    .padding(4).background(Color.black.opacity(0.1)).clipShape(Circle())
            }
        }
        .padding(.leading, 8).padding([.trailing, .vertical], 4)
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
}

// MARK: - Supporting Components

private struct SectionHeaderLabel: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(DesignSystem.Typography.callout)
                .symbolRenderingMode(.hierarchical)
                .padding(6)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(title)
                .sectionHeaderStyle()
        }
    }
}

private struct DepartmentInputRow: View {
    @Binding var item: DepartmentItem
    let errorMessage: String?
    @ObservedObject var viewModel: CreateProjectViewModel
    let phaseId: UUID
    let canDelete: Bool
    let onDelete: () -> Void
    @State private var rawAmountInput: String = ""
    @State private var contractorMode: ContractorMode = .labourOnly
    @State private var lineItems: [DepartmentLineItem] = [DepartmentLineItem()]
    @State private var isExpanded: Bool = false
    @State private var showingLineItemSheet = false
    @State private var editingLineItem: DepartmentLineItem?
    @State private var isNewLineItem = false
    
    private var totalDepartmentBudget: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }
    
    // MARK: - Computed Views (to help compiler type-check)
    private var collapsedView: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            departmentNameField
            budgetField
            expandCollapseButton
        }
    }
    
    private var departmentNameField: some View {
        VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.grid.3x3.square")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.blue)
                            .symbolRenderingMode(.hierarchical)
                            .padding(4)
//                            .background(Color.blue)
                            .clipShape(Circle())
                        Text("Department")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        if canDelete {
                            Button(action: {
                                HapticManager.selection()
                                onDelete()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            .font(.system(size: 9))
                            .frame(width: 14, height: 14)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Delete department")
                            .accessibilityHint("Removes this department from the phase")
                        }
                    }
                    
                    TextField("e.g., Marketing", text: $item.name)
                .font(.system(size: 14))
                        .textFieldStyle(.plain)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.extraSmall)
                        .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(DesignSystem.CornerRadius.small)
                        .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                        )
        }
                }
                
    private var budgetField: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 4) {
                        Text("Budget")
                    .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                                        
//                        if canDelete {
//                            Button(action: {
//                                HapticManager.selection()
//                                onDelete()
//                            }) {
//                                Image(systemName: "trash")
//                                    .foregroundColor(.red)
//                            .font(.system(size: 9))
//                            .frame(width: 14, height: 14)
//                                    .contentShape(Rectangle())
//                            }
//                            .buttonStyle(.plain)
//                            .accessibilityLabel("Delete department")
//                            .accessibilityHint("Removes this department from the phase")
//                        }
                    }
                    
                    Text(totalDepartmentBudget.formattedCurrency)
                .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                .frame(minWidth: 80, alignment: .trailing)
        }
                }
                
    private var expandCollapseButton: some View {
                Button(action: {
                    HapticManager.selection()
                    withAnimation(DesignSystem.Animation.standardSpring) {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
    private var expandedView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Divider()
            contractorModeSection
            lineItemsSection
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
                    
    private var contractorModeSection: some View {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Contractor Mode")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        HStack(spacing: DesignSystem.Spacing.small) {
                            ForEach(ContractorMode.allCases, id: \.self) { mode in
                    contractorModeButton(for: mode)
                }
            }
        }
    }
    
    private func contractorModeButton(for mode: ContractorMode) -> some View {
                                Button(action: {
                                    HapticManager.selection()
                                    let previousMode = contractorMode
                                    contractorMode = mode
                                    
                                    // If switching to Labour-Only, clear non-Labour item types
                                    if mode == .labourOnly && previousMode == .turnkey {
                                        for index in lineItems.indices {
                                            if lineItems[index].itemType != "Labour" && !lineItems[index].itemType.isEmpty {
                                                lineItems[index].itemType = ""
                                                lineItems[index].item = ""
                                                lineItems[index].spec = ""
                                            }
                                        }
                                    }
                                }) {
                                    Text(mode.displayName)
                .font(.system(size: 14, weight: contractorMode == mode ? .semibold : .regular))
                                        .foregroundColor(contractorMode == mode ? .blue : .primary)
                                        .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.small)
                .padding(.vertical, DesignSystem.Spacing.small)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                                .fill(contractorMode == mode ? Color.blue.opacity(0.12) : Color(.tertiarySystemGroupedBackground))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                                .stroke(contractorMode == mode ? Color.blue.opacity(0.3) : Color(.separator), lineWidth: contractorMode == mode ? 1.5 : 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
    
    private var lineItemsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            lineItemsHeader
            lineItemsList
            addLineItemButton
            lineItemsTotal
        }
        .padding(DesignSystem.Spacing.small)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(DesignSystem.CornerRadius.small)
    }
    
    private var lineItemsHeader: some View {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Items")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Spacer()
                            
                            Text("sum must equal Department Budget")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(.secondary)
                                .italic()
        }
                        }
                        
    private var lineItemsList: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
                            ForEach($lineItems) { $lineItem in
                                LineItemRowView(
                                    lineItem: $lineItem,
                                    onDelete: {
                                        if lineItems.count > 1 {
                                            lineItems.removeAll { $0.id == lineItem.id }
                                            updateDepartmentBudget()
                                        }
                                    },
                                    canDelete: lineItems.count > 1,
                                    contractorMode: contractorMode,
                                    onEdit: {
                                        editingLineItem = lineItem
                                        isNewLineItem = false
                                        showingLineItemSheet = true
                                    }
                                )
                            }
                        }
                        .sheet(isPresented: $showingLineItemSheet) {
                            if let editingItem = editingLineItem,
                               let index = lineItems.firstIndex(where: { $0.id == editingItem.id }) {
                                LineItemEditSheet(
                                    lineItem: $lineItems[index],
                                    contractorMode: contractorMode,
                                    isNewItem: isNewLineItem,
                                    onSave: {
                                        updateDepartmentBudget()
                                    },
                                    onCancel: {
                                        // If it's a new item and user cancels, remove it
                                        if isNewLineItem, let editingItem = editingLineItem {
                                            lineItems.removeAll { $0.id == editingItem.id }
                                        }
                                    }
                                )
            }
                            }
                        }
                        
    private var addLineItemButton: some View {
                        Button(action: {
                            HapticManager.selection()
                            let newItem = DepartmentLineItem()
                            lineItems.append(newItem)
                            editingLineItem = newItem
                            isNewLineItem = true
                            showingLineItemSheet = true
                        }) {
            HStack(spacing: DesignSystem.Spacing.extraSmall) {
                                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                                Text("Add row")
                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.extraSmall)
                        }
                        .buttonStyle(.plain)
    }
                        
    private var lineItemsTotal: some View {
        VStack(spacing: 0) {
                        Divider()
                .padding(.vertical, DesignSystem.Spacing.extraSmall)
                        
                        HStack {
                            Text("Total")
                    .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(totalDepartmentBudget.formattedCurrency)
                    .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            collapsedView
            
            if isExpanded {
                expandedView
            }
            
            if let error = errorMessage {
                InlineErrorMessage(message: error)
            }
            
            Divider()
        }
        .padding(.vertical, DesignSystem.Spacing.extraSmall)
        .onAppear {
            // Initialize from template data - prioritize item.lineItems if available
            if !item.lineItems.isEmpty {
                // Check if current lineItems is just an empty placeholder
                let hasOnlyEmptyItem = lineItems.count == 1 && (lineItems.first?.itemType.isEmpty ?? true) && (lineItems.first?.item.isEmpty ?? true)
                
                if hasOnlyEmptyItem || lineItems.isEmpty {
                    // Replace with template line items
                    lineItems = item.lineItems
                    print("📦 DepartmentInputRow: Loaded \(lineItems.count) line items from template for '\(item.name)'")
                }
            } else {
                // If no template line items, ensure we have at least one empty item for user input
                if lineItems.isEmpty {
                    lineItems = [DepartmentLineItem()]
                }
            }
            
            // Initialize contractor mode from template
            contractorMode = item.contractorMode
            
            // Calculate and set budget from line items
            let calculatedBudget = lineItems.reduce(0) { $0 + $1.total }
            if item.amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || item.amount == "₹0.00" || item.amount == "0" {
                // Calculate from line items if amount is empty/zero
                if calculatedBudget > 0 {
                    updateDepartmentBudget()
                    print("💰 DepartmentInputRow: Calculated budget \(item.amount) for '\(item.name)' from \(lineItems.count) line items (total: \(calculatedBudget))")
                } else {
                    rawAmountInput = item.amount.isEmpty ? "₹0.00" : item.amount
                }
            } else {
                rawAmountInput = item.amount
                print("💰 DepartmentInputRow: Using stored budget \(item.amount) for '\(item.name)' (calculated: \(calculatedBudget))")
            }
        }
        .onChange(of: item.lineItems) { oldValue, newValue in
            // Sync when item.lineItems changes (from template loading)
            if !newValue.isEmpty {
                let hasOnlyEmptyItem = lineItems.count == 1 && (lineItems.first?.itemType.isEmpty ?? true) && (lineItems.first?.item.isEmpty ?? true)
                
                if hasOnlyEmptyItem || lineItems.isEmpty || (lineItems.count != newValue.count) {
                    lineItems = newValue
                    contractorMode = item.contractorMode
                    updateDepartmentBudget()
                    print("🔄 DepartmentInputRow: Synced \(lineItems.count) line items for '\(item.name)'")
                }
            }
        }
        .onChange(of: totalDepartmentBudget) { oldValue, newValue in
            updateDepartmentBudget()
        }
        .onChange(of: lineItems) { oldValue, newValue in
            // Sync lineItems back to item
            item.lineItems = newValue
        }
        .onChange(of: contractorMode) { oldValue, newValue in
            // Sync contractorMode back to item
            item.contractorMode = newValue
        }
    }
    
    private func updateDepartmentBudget() {
        let formatted = viewModel.formatAmountInput(String(totalDepartmentBudget))
        item.amount = formatted
        rawAmountInput = formatted
    }
}

// MARK: - Form Section View (ScrollView compatible)
struct FormSectionView<Content: View, Header: View>: View {
    let header: Header
    let content: Content
    
    init(header: Header, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Header
            header
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .padding(.top, DesignSystem.Spacing.medium)
            
            // Content
            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .padding(.horizontal, DesignSystem.Spacing.medium)
        }
    }
}

// MARK: - Inline Error Message View
struct InlineErrorMessage: View {
    let message: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .font(.system(size: 14, weight: .medium))
            
            Text(message)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(.red)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.top, DesignSystem.Spacing.extraSmall)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

// MARK: - Project Document Picker
struct ProjectDocumentPicker: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    let onDocumentPicked: (Result<[URL], Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        picker.shouldShowFileExtensions = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: ProjectDocumentPicker
        
        init(_ parent: ProjectDocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onDocumentPicked(.success(urls))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation if needed
        }
    }
}

// MARK: - Project Image Picker
struct ProjectImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ProjectImagePicker
        
        init(_ parent: ProjectImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                            return
                        }
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// MARK: - Project Camera Picker
struct ProjectCameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ProjectCameraPicker
        
        init(_ parent: ProjectCameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Extract image on main thread
            DispatchQueue.main.async {
                if let editedImage = info[.editedImage] as? UIImage {
                    self.parent.selectedImage = editedImage
                } else if let originalImage = info[.originalImage] as? UIImage {
                    self.parent.selectedImage = originalImage
                }
            }
            
            // Dismiss the picker first
            picker.dismiss(animated: true) {
                // After picker dismisses, dismiss the sheet
                DispatchQueue.main.async {
                    self.parent.onDismiss()
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                // After picker dismisses, dismiss the sheet
                DispatchQueue.main.async {
                    self.parent.onDismiss()
                }
            }
        }
    }
}

// MARK: - Create Project Add Department Sheet
private struct CreateProjectAddDepartmentSheet: View {
    let phaseId: UUID
    let phaseName: String
    @ObservedObject var viewModel: CreateProjectViewModel
    var onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var departmentName: String = ""
    @State private var contractorMode: ContractorMode = .labourOnly
    @State private var lineItems: [DepartmentLineItem] = [DepartmentLineItem()]
    @State private var showingLineItemSheet = false
    @State private var editingLineItem: DepartmentLineItem?
    @State private var isNewLineItem = false
    @State private var departmentNameError: String?
    @FocusState private var focusedField: Field?
    
    private enum Field { case name }
    
    private var isFormValid: Bool {
        guard !departmentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
              departmentNameError == nil else {
            return false
        }
        
        // Validate that all line items have UOM
        for lineItem in lineItems {
            if lineItem.uom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }
        }
        
        return true
    }
    
    private var totalDepartmentBudget: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }
    
    private func validateDepartmentName() {
        let trimmedName = departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            departmentNameError = nil
            return
        }
        
        // Check for duplicate department names within the same phase
        if let phase = viewModel.phases.first(where: { $0.id == phaseId }) {
            let isDuplicate = phase.departments.contains { dept in
                dept.id != phaseId && dept.name.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
            }
            
            if isDuplicate {
                departmentNameError = "\"\(trimmedName)\" already exists in \"\(phaseName)\". Enter a unique department name."
            } else {
                departmentNameError = nil
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Drag Indicator
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.secondary.opacity(0.25))
                        .frame(width: 36, height: 5)
                        .padding(.top, DesignSystem.Spacing.medium)
                        .padding(.bottom, DesignSystem.Spacing.large)
                    
                    // Header Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Add Department")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: DesignSystem.Spacing.extraSmall) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("to \(phaseName)")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.large)
                    
                    // Department Name Card
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Label {
                            Text("Department Name")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "building.2")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        TextField("Enter department name", text: $departmentName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .name)
                            .font(.system(size: 17, weight: .regular))
                            .padding(.horizontal, DesignSystem.Spacing.medium)
                            .padding(.vertical, DesignSystem.Spacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.tertiarySystemGroupedBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(departmentNameError != nil ? Color.red.opacity(0.6) : Color.clear, lineWidth: 1.5)
                            )
                            .onChange(of: departmentName) { _, _ in
                                validateDepartmentName()
                            }
                        
                        if let error = departmentNameError {
                            HStack(spacing: DesignSystem.Spacing.extraSmall) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.red)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, DesignSystem.Spacing.extraSmall)
                        }
                    }
                    .padding(DesignSystem.Spacing.medium)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
                    
                    // Contractor Mode Card
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Label {
                            Text("Contractor Mode")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        } icon: {
                            Image(systemName: "person.2")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        HStack(spacing: DesignSystem.Spacing.small) {
                            ForEach(ContractorMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    HapticManager.selection()
                                    let previousMode = contractorMode
                                    contractorMode = mode
                                    
                                    // If switching to Labour-Only, clear non-Labour item types
                                    if mode == .labourOnly && previousMode == .turnkey {
                                        for index in lineItems.indices {
                                            if lineItems[index].itemType != "Labour" && !lineItems[index].itemType.isEmpty {
                                                lineItems[index].itemType = ""
                                                lineItems[index].item = ""
                                                lineItems[index].spec = ""
                                            }
                                        }
                                    }
                                }) {
                                    Text(mode.displayName)
                                        .font(.system(size: 15, weight: contractorMode == mode ? .semibold : .regular))
                                        .foregroundColor(contractorMode == mode ? .white : .primary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, DesignSystem.Spacing.medium)
                                        .padding(.vertical, DesignSystem.Spacing.medium)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(contractorMode == mode ? Color.blue : Color(.tertiarySystemGroupedBackground))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.medium)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.bottom, DesignSystem.Spacing.medium)
                    
                    // Line Items Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Items")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Spacer()
                            
                            Text("sum must equal Department Budget")
                                .font(DesignSystem.Typography.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach($lineItems) { $lineItem in
                                LineItemRowView(
                                    lineItem: $lineItem,
                                    onDelete: {
                                        if lineItems.count > 1 {
                                            lineItems.removeAll { $0.id == lineItem.id }
                                        }
                                    },
                                    canDelete: lineItems.count > 1,
                                    contractorMode: contractorMode,
                                    onEdit: {
                                        editingLineItem = lineItem
                                        isNewLineItem = false
                                        showingLineItemSheet = true
                                    }
                                )
                            }
                        }
                        .sheet(isPresented: $showingLineItemSheet) {
                            if let editingItem = editingLineItem,
                               let index = lineItems.firstIndex(where: { $0.id == editingItem.id }) {
                                LineItemEditSheet(
                                    lineItem: $lineItems[index],
                                    contractorMode: contractorMode,
                                    isNewItem: isNewLineItem,
                                    onSave: {
                                        // Budget updates automatically
                                    },
                                    onCancel: {
                                        // If it's a new item and user cancels, remove it
                                        if isNewLineItem, let editingItem = editingLineItem {
                                            lineItems.removeAll { $0.id == editingItem.id }
                                        }
                                    }
                                )
                            }
                        }
                        
                        Button(action: {
                            HapticManager.selection()
                            let newItem = DepartmentLineItem()
                            lineItems.append(newItem)
                            editingLineItem = newItem
                            isNewLineItem = true
                            showingLineItemSheet = true
                        }) {
                            HStack(spacing: DesignSystem.Spacing.small) {
                                Image(systemName: "square.fill.text.grid.1x2")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                Text("Add Line Item")
                                    .font(DesignSystem.Typography.callout)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DesignSystem.Spacing.small)
                        }
                        .buttonStyle(.plain)
                        
                        // Total Display
                        Divider()
                            .padding(.vertical, DesignSystem.Spacing.small)
                        
                        HStack {
                            Text("Total")
                                .font(DesignSystem.Typography.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(totalDepartmentBudget.formattedCurrency)
                                .font(DesignSystem.Typography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(DesignSystem.Spacing.medium)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                }
                .padding(.bottom, DesignSystem.Spacing.extraLarge)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Department")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.blue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveDepartment()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
    }
    
    private func saveDepartment() {
        validateDepartmentName()
        
        guard isFormValid else {
            return
        }
        
        // Create department item
        var department = DepartmentItem()
        department.name = departmentName.trimmingCharacters(in: .whitespacesAndNewlines)
        department.contractorMode = contractorMode
        department.lineItems = lineItems
        
        // Add to phase directly
        if let phaseIndex = viewModel.phases.firstIndex(where: { $0.id == phaseId }) {
            viewModel.phases[phaseIndex].departments.append(department)
        }
        
        onSaved()
    }
}

// MARK: - Create Project Add Phase Sheet
private struct CreateProjectAddPhaseSheet: View {
    @ObservedObject var viewModel: CreateProjectViewModel
    var onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var phaseName: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400 * 30)
    @State private var departments: [DepartmentItem] = [DepartmentItem()]
    @State private var expandedDepartmentId: UUID? = nil
    @State private var expandedLineItemIds: [UUID: UUID] = [:]
    @State private var phaseNameError: String?
    @FocusState private var focusedField: Field?
    
    private enum Field { case phaseName }
    
    private var isFormValid: Bool {
        let trimmedName = phaseName.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasValidDepartments = !departments.isEmpty &&
        departments.contains { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        return !trimmedName.isEmpty &&
        phaseNameError == nil &&
        endDate > startDate &&
        hasValidDepartments
    }
    
    private func validatePhaseName() {
        let trimmedName = phaseName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            phaseNameError = nil
            return
        }
        
        // Check for duplicate phase names
        let isDuplicate = viewModel.phases.contains { phase in
            phase.phaseName.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
        
        if isDuplicate {
            phaseNameError = "\"\(trimmedName)\" already exists. Enter a unique phase name."
        } else {
            phaseNameError = nil
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Drag Indicator
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 36, height: 5)
                        .padding(.top, DesignSystem.Spacing.small)
                        .padding(.bottom, DesignSystem.Spacing.extraSmall)
                    
                    // Phase Name Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("Add Phase")
                            .font(DesignSystem.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.bottom, DesignSystem.Spacing.extraSmall)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Phase Name")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            TextField("Enter phase name", text: $phaseName)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .phaseName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.horizontal, DesignSystem.Spacing.large)
                                .padding(.vertical, DesignSystem.Spacing.medium)
                                .background(
                                    Group {
                                        if phaseNameError != nil {
                                            // Error state - red gradient
                                            LinearGradient(
                                                colors: [.red.opacity(0.1), .red.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        } else {
                                            // Normal state - green, blue, purple gradient
                                            LinearGradient(
                                                colors: [
                                                    Color.green.opacity(0.15),
                                                    Color.blue.opacity(0.15),
                                                    Color.purple.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            phaseNameError != nil
                                                ? LinearGradient(
                                                    colors: [.red, .red.opacity(0.6)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                : LinearGradient(
                                                    colors: [
                                                        Color.green.opacity(0.4),
                                                        Color.blue.opacity(0.4),
                                                        Color.purple.opacity(0.4)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                            lineWidth: phaseNameError != nil ? 2 : 1.5
                                        )
                                )
                                .onChange(of: phaseName) { _, _ in
                                    validatePhaseName()
                                }
                            
                            if let error = phaseNameError {
                                HStack(spacing: DesignSystem.Spacing.extraSmall) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(.red)
                                }
                                .padding(.top, DesignSystem.Spacing.extraSmall)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.top, DesignSystem.Spacing.medium)
                    
                    // Timeline Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("Timeline")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                                Text("Start Date")
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(.secondary)
                                
                                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                                Text("End Date")
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(.secondary)
                                
                                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                            
                            if endDate <= startDate {
                                HStack(spacing: DesignSystem.Spacing.extraSmall) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.orange)
                                    Text("End date must be after start date")
                                        .font(DesignSystem.Typography.caption1)
                                        .foregroundColor(.orange)
                                }
                                .padding(.top, DesignSystem.Spacing.extraSmall)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    
                    // Departments Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Departments")
                                .font(DesignSystem.Typography.caption1)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach($departments) { $dept in
                                // Simplified department row for phase creation
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                                    TextField("Department name", text: $dept.name)
                                        .font(DesignSystem.Typography.body)
                                        .padding(.horizontal, DesignSystem.Spacing.medium)
                                        .padding(.vertical, DesignSystem.Spacing.small)
                                        .background(Color(.tertiarySystemGroupedBackground))
                                        .cornerRadius(DesignSystem.CornerRadius.field)
                                }
                            }
                            
                            Button(action: {
                                HapticManager.selection()
                                departments.append(DepartmentItem())
                            }) {
                                HStack(spacing: DesignSystem.Spacing.small) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Add Department")
                                        .font(DesignSystem.Typography.callout)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.small)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(DesignSystem.Spacing.medium)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                }
                .padding(.bottom, DesignSystem.Spacing.extraLarge)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Phase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.blue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        savePhase()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            }
            .onAppear {
                focusedField = .phaseName
            }
        }
    }
    
    private func savePhase() {
        validatePhaseName()
        
        guard isFormValid else {
            return
        }
        
        // Create phase item
        var phase = PhaseItem(phaseNumber: viewModel.phases.count + 1)
        phase.phaseName = phaseName.trimmingCharacters(in: .whitespacesAndNewlines)
        phase.startDate = startDate
        phase.endDate = endDate
        phase.hasStartDate = true
        phase.hasEndDate = true
        phase.departments = departments.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        // Add to view model
        viewModel.phases.append(phase)
        
        onSaved()
    }
}

// MARK: - Preview Provider
struct CreateProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProjectView()
    }
}
