import SwiftUI
import UniformTypeIdentifiers
import PhotosUI
import AVFoundation

struct AddExpenseView: View {
    let project: Project
    @StateObject private var viewModel: AddExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var showingFileViewer = false
    @State private var showingCamera = false
    @State private var showingPaymentProofFileViewer = false
    @State private var showingPaymentProofCamera = false
    
    init(project: Project) {
        self.project = project
        self._viewModel = StateObject(wrappedValue: AddExpenseViewModel(project: project, customerId: nil))
    }
    
    private var customerId: String? {
        authService.currentCustomerId
    }
    
    // MARK: - Helper Functions
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        return formatter.string(from: NSNumber(value: amount)) ?? "₹0.00"
    }
    
    private func formatDepartmentName(_ departmentName: String) -> String {
        // Remove everything before and including the first underscore
        if let underscoreIndex = departmentName.firstIndex(of: "_") {
            let afterUnderscore = departmentName.index(after: underscoreIndex)
            return String(departmentName[afterUnderscore...])
        }
        // If no underscore found, return the original name
        return departmentName
    }
    
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
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                formContent(proxy: proxy)
                    .navigationTitle("New Expense")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                    .modifier(FormModifiers(
                        viewModel: viewModel,
                        proxy: proxy,
                        showingCamera: $showingCamera,
                        showingPaymentProofCamera: $showingPaymentProofCamera,
                        showingFileViewer: $showingFileViewer,
                        showingPaymentProofFileViewer: $showingPaymentProofFileViewer,
                        customerId: customerId,
                        dismiss: dismiss
                    ))
            }
        }
    }
    
    // MARK: - Form Modifiers
    private struct FormModifiers: ViewModifier {
        @ObservedObject var viewModel: AddExpenseViewModel
        let proxy: ScrollViewProxy
        @Binding var showingCamera: Bool
        @Binding var showingPaymentProofCamera: Bool
        @Binding var showingFileViewer: Bool
        @Binding var showingPaymentProofFileViewer: Bool
        let customerId: String?
        let dismiss: DismissAction
        
        func body(content: Content) -> some View {
            content
                .onChange(of: viewModel.firstInvalidFieldId) { fieldId in
                    if let fieldId = fieldId {
                        print("🔄 Attempting to scroll to field: \(fieldId)")
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                            withAnimation(.easeInOut(duration: 0.6)) {
                                proxy.scrollTo(fieldId, anchor: .top)
                            }
                        }
                    }
                }
                .alert("Status", isPresented: $viewModel.showAlert) {
                    Button("OK") {
                        if viewModel.shouldDismissOnAlert {
                            dismiss()
                        }
                    }
                } message: {
                    Text(viewModel.alertMessage)
                }
                .confirmationDialog("Select Receipt", isPresented: $viewModel.showingAttachmentOptions, titleVisibility: .visible) {
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
                .confirmationDialog("Select Payment Proof", isPresented: $viewModel.showingPaymentProofOptions, titleVisibility: .visible) {
                    Button("Camera") {
                        showingPaymentProofCamera = true
                    }
                    
                    Button("Select from Photos") {
                        viewModel.showingPaymentProofImagePicker = true
                    }
                    
                    Button("Select from Files") {
                        viewModel.showingPaymentProofDocumentPicker = true
                    }
                    
                    Button("Cancel", role: .cancel) { }
                }
                .sheet(isPresented: $viewModel.showingImagePicker) {
                    ExpenseImagePicker(selectedImage: Binding(
                        get: { nil },
                        set: { image in
                            viewModel.handleImageSelection(image)
                        }
                    ))
                }
                .sheet(isPresented: $viewModel.showingDocumentPicker) {
                    DocumentPicker(
                        allowedTypes: [.pdf, .image],
                        onDocumentPicked: viewModel.handleDocumentSelection
                    )
                }
                .sheet(isPresented: $showingCamera) {
                    ExpenseCameraPicker(
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
                .sheet(isPresented: $viewModel.showingPaymentProofImagePicker) {
                    ExpenseImagePicker(selectedImage: Binding(
                        get: { nil },
                        set: { image in
                            viewModel.handlePaymentProofImageSelection(image)
                        }
                    ))
                }
                .sheet(isPresented: $viewModel.showingPaymentProofDocumentPicker) {
                    DocumentPicker(
                        allowedTypes: [.pdf, .image],
                        onDocumentPicked: viewModel.handlePaymentProofDocumentSelection
                    )
                }
                .sheet(isPresented: $showingPaymentProofCamera) {
                    ExpenseCameraPicker(
                        selectedImage: Binding(
                            get: { nil },
                            set: { image in
                                viewModel.handlePaymentProofImageSelection(image)
                            }
                        ),
                        onDismiss: {
                            showingPaymentProofCamera = false
                        }
                    )
                }
                .sheet(isPresented: $showingFileViewer) {
                    if let urlString = viewModel.attachmentURL,
                       let url = URL(string: urlString) {
                        FileViewerSheet(fileURL: url, fileName: viewModel.attachmentName)
                    }
                }
                .sheet(isPresented: $showingPaymentProofFileViewer) {
                    if let urlString = viewModel.paymentProofURL,
                       let url = URL(string: urlString) {
                        FileViewerSheet(fileURL: url, fileName: viewModel.paymentProofName)
                    }
                }
                .onAppear {
                    UserServices.shared.currentUserPhone
                    // Update customerId in ViewModel when it becomes available
                    if let customerId = customerId {
                        viewModel.updateCustomerId(customerId)
                    }
                }
                .onChange(of: viewModel.expenseDate) { newDate in
                    // Reload phases when date changes
                    viewModel.loadPhases(for: newDate)
                }
                .onChange(of: viewModel.selectedPhaseId) { _ in
                    viewModel.checkBusinessHeadApprovalConditions()
                }
                .onChange(of: viewModel.selectedDepartment) { _ in
                    viewModel.loadAvailableItemTypes()
                    viewModel.checkBusinessHeadApprovalConditions()
                }
                .onChange(of: viewModel.quantity) { _ in
                    viewModel.checkBusinessHeadApprovalConditions()
                }
                .onChange(of: viewModel.unitPrice) { _ in
                    viewModel.checkBusinessHeadApprovalConditions()
                }
        }
    }
    
    private func formContent(proxy: ScrollViewProxy) -> some View {
        Form {
                // MARK: - Project Header
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.secondary)
                            Text("Tracura")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - Expense Date
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expense Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        DatePicker("Select expense date", selection: $viewModel.expenseDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text("Phase selection will be filtered based on this date")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Expense Details")
                        .textCase(.none)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Phase and Department Selection (Side by Side)
                Section {
                    HStack(spacing: 12) {
                        // Phase
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phase")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            
                            Menu {
                                let availablePhases = viewModel.availablePhases.filter { $0.canAddExpense }
                                if !availablePhases.isEmpty {
                                    ForEach(availablePhases) { phase in
                                        Button {
                                            viewModel.selectedPhaseId = phase.id
                                            viewModel.updateDepartmentForPhase()
                                        } label: {
                                            Text(phase.name)
                                        }
                                    }
                                } else {
                                    Text("No phases available")
                                        .foregroundColor(.secondary)
                                        .disabled(true)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    if let selectedPhase = viewModel.selectedPhase {
                                        Text(selectedPhase.name)
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text("Remaining: \(formatCurrency(selectedPhase.remainingAmount))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text("Select Phase")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Department
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Department")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            
                            if let selectedPhase = viewModel.selectedPhase {
                                Menu {
                                    let sortedDepts = selectedPhase.departments.sorted(by: { $0.name < $1.name })
                                    ForEach(sortedDepts, id: \.id) { department in
                                        let deptKey = String.departmentKey(phaseId: selectedPhase.id, departmentName: department.name)
                                        Button {
                                            viewModel.selectedDepartment = deptKey
                                            viewModel.loadAvailableItemTypes()
                                            viewModel.checkBusinessHeadApprovalConditions()
                                        } label: {
                                            HStack {
                                                Text(department.name)
                                                Spacer()
                                                Text(formatCurrency(department.remainingAmount))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if !viewModel.selectedDepartment.isEmpty,
                                           let selectedDept = selectedPhase.departments.first(where: { dept in
                                               String.departmentKey(phaseId: selectedPhase.id, departmentName: dept.name) == viewModel.selectedDepartment
                                           }) {
                                            Text(selectedDept.name)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            Text("Remaining: \(formatCurrency(selectedDept.remainingAmount))")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("Select Department")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(10)
                                }
                                .disabled(!selectedPhase.canAddExpense)
                            } else {
                                Text("Select Phase first")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // BusinessHead approval message
                    if let message = viewModel.businessHeadApprovalMessage {
                        BusinessHeadApprovalMessageView(message: message)
                    }
                } header: {
                    Text("Phase Selection")
                        .textCase(.none)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } footer: {
                    if !viewModel.availablePhases.filter({ $0.canAddExpense }).isEmpty {
                        Text("Phases are filtered based on the selected expense date")
                            .font(.caption)
                    } else {
                        Text("No phases available for the selected date. Please select a different date.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // MARK: - Material Details
                Section {
                    materialDetailsView
                } header: {
                    Text("Material Details")
                        .textCase(.none)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Notes
                Section {
                    notesView
                } header: {
                    Text("Notes")
                        .textCase(.none)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Payment Mode
                Section {
                    paymentModeView
                } header: {
                    Text("Mode of Payment")
                        .textCase(.none)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                    
                // MARK: - Payment Proof (Required for UPI and Cheque)
                if viewModel.selectedPaymentMode == .upi || viewModel.selectedPaymentMode == .cheque {
                    Section {
                        paymentProofView
                    } header: {
                        Text("Payment Proof")
                            .textCase(.none)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } footer: {
                        Text("Payment proof is required for UPI and cheque payments")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Receipt
                Section {
                    receiptView
                } header: {
                    Text("Receipt")
                        .textCase(.none)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                

                
                // MARK: - Submit Button
                Section {
                    submitButton
                }
        }
    }
    
    
    // MARK: - Phase Picker
    private var phasePickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Phase")
                .font(.subheadline)
                .foregroundColor(.primary)
                .fontWeight(.medium)
            
            Menu {
                // Show only phases that can accept expenses for the selected date
                let availablePhases = viewModel.availablePhases.filter { $0.canAddExpense }
                if !availablePhases.isEmpty {
                    ForEach(availablePhases) { phase in
                        Button {
                            viewModel.selectedPhaseId = phase.id
                            viewModel.updateDepartmentForPhase()
                        } label: {
                            HStack {
                                TruncatedTextWithTooltip(
                                    phase.name,
                                    font: .body,
                                    foregroundColor: .primary,
                                    lineLimit: 1
                                )
                                Spacer()
                                Text(formatCurrency(phase.remainingAmount))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    Text("No phases available for selected date")
                        .foregroundColor(.secondary)
                        .disabled(true)
                }
                
                // Show disabled/out-of-timeline phases at the bottom with indicators
                let disabledPhases = viewModel.availablePhases.filter { !$0.canAddExpense }
                if !disabledPhases.isEmpty {
                    Divider()
                    
                    ForEach(disabledPhases) { phase in
                        Button {
                            // Do nothing - disabled
                        } label: {
                            HStack {
                                TruncatedTextWithTooltip(
                                    phase.name,
                                    font: .body,
                                    foregroundColor: .primary,
                                    lineLimit: 1
                                )
                                Spacer()
                                if !phase.isEnabled {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                } else {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .disabled(true)
                    }
                }
            } label: {
                HStack {
                    if let selectedPhase = viewModel.selectedPhase {
                        VStack(alignment: .leading, spacing: 4) {
                            TruncatedTextWithTooltip(
                                selectedPhase.name,
                                font: .body,
                                fontWeight: .medium,
                                foregroundColor: .primary,
                                lineLimit: 1
                            )
                            Text("Remaining: \(formatCurrency(selectedPhase.remainingAmount))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Select Phase")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill))
                .cornerRadius(8)
            }
            
            // Show info about disabled phases if selected phase is not available
            if let selectedPhase = viewModel.selectedPhase, !selectedPhase.canAddExpense {
                HStack(spacing: 6) {
                    Image(systemName: selectedPhase.isEnabled ? "calendar.badge.exclamationmark" : "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text(selectedPhase.isEnabled ? "This phase is not available for the selected expense date" : "This phase is disabled")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
            
            if let error = viewModel.phaseError {
                InlineErrorMessage(message: error)
            }
        }
        .id("phase")
        .padding(.vertical, 4)
    }
    
    // MARK: - Department Picker
    private var departmentPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Department")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            if let selectedPhase = viewModel.selectedPhase {
                Menu {
                    let sortedDepartments = selectedPhase.departments.sorted(by: { $0.name < $1.name })
                    ForEach(sortedDepartments, id: \.id) { department in
                        let deptKey = String.departmentKey(phaseId: selectedPhase.id, departmentName: department.name)
                        Button {
                            viewModel.selectedDepartment = deptKey
                            viewModel.loadAvailableItemTypes()
                            viewModel.checkBusinessHeadApprovalConditions()
                        } label: {
                            HStack {
                                TruncatedTextWithTooltip(
                                    department.name,
                                    font: .body,
                                    foregroundColor: .primary,
                                    lineLimit: 1
                                )
                                Spacer()
                                Text(formatCurrency(department.remainingAmount))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.selectedDepartment.isEmpty {
                            Text("Select Department")
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                if let selectedDept = selectedPhase.departments.first(where: { dept in
                                    String.departmentKey(phaseId: selectedPhase.id, departmentName: dept.name) == viewModel.selectedDepartment
                                }) {
                                    TruncatedTextWithTooltip(
                                        selectedDept.name,
                                        font: .body,
                                        fontWeight: .medium,
                                        foregroundColor: .primary,
                                        lineLimit: 1
                                    )
                                    Text("Remaining: \(formatCurrency(selectedDept.remainingAmount))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text(formatDepartmentName(viewModel.selectedDepartment))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemFill))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.departmentError != nil ? Color.red : Color.clear, lineWidth: 1)
                    )
                }
                .disabled(!selectedPhase.canAddExpense)
            } else {
                Text("Please select a phase first")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let error = viewModel.departmentError {
                InlineErrorMessage(message: error)
            }
        }
        .id("department")
        .padding(.vertical, 4)
    }
    
    // MARK: - Material Details View (Card-based Design)
    private var materialDetailsView: some View {
        VStack(spacing: 12) {
            // Sub-category (Global) - Full Width
            VStack(alignment: .leading, spacing: 6) {
                Text("Sub-category (Global)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Menu {
                    ForEach(viewModel.availableItemTypes, id: \.self) { itemType in
                        Button {
                            let previousItemType = viewModel.selectedItemType
                            viewModel.selectedItemType = itemType
                            viewModel.selectedItem = ""
                            viewModel.selectedSpec = ""
                            
                            // Clear brand, spec, and thickness when switching to Labour
                            if itemType == "Labour" {
                                viewModel.brand = ""
                                viewModel.selectedSpec = ""
                                viewModel.thickness = "16 mm" // Reset to default
                                // Set default UOM for Labour if empty
                                if viewModel.uom.isEmpty {
                                    viewModel.uom = DepartmentItemData.uomOptions(for: "Labour").first ?? ""
                                } else {
                                    // Validate UOM is valid for Labour
                                    let labourUOMs = DepartmentItemData.uomOptions(for: "Labour")
                                    if !labourUOMs.contains(viewModel.uom) {
                                        viewModel.uom = labourUOMs.first ?? ""
                                    }
                                }
                            } else {
                                // Reset UOM to default for non-Labour items
                                if previousItemType == "Labour" {
                                    viewModel.uom = "ton"
                                }
                            }
                        } label: {
                            Text(itemType)
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedItemType.isEmpty ? "Select Sub-category" : viewModel.selectedItemType)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.selectedItemType.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }
            }
            
            // Material/Gender - Full Width (Brand hidden for Labour)
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.selectedItemType == "Labour" ? "Gender" : "Material")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                if !viewModel.selectedItemType.isEmpty {
                    Menu {
                        ForEach(viewModel.availableItems, id: \.self) { item in
                            Button {
                                viewModel.selectedItem = item
                                viewModel.selectedSpec = ""
                            } label: {
                                Text(item)
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedItem.isEmpty ? (viewModel.selectedItemType == "Labour" ? "Select Gender" : "Select Material") : viewModel.selectedItem)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(viewModel.selectedItem.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    }
                } else {
                    Text("Select Sub-category first")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
            }
            
            // Brand and Grade/Thickness - Hidden for Labour
            if viewModel.selectedItemType != "Labour" {
                // Brand
                VStack(alignment: .leading, spacing: 6) {
                    Text("Brand")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    TextField("Optional", text: $viewModel.brand)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                
                // Grade and Thickness - Side by Side
                HStack(spacing: 12) {
                    // Grade
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Grade")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        if !viewModel.selectedItemType.isEmpty && !viewModel.selectedItem.isEmpty {
                            Menu {
                                ForEach(viewModel.availableSpecs, id: \.self) { spec in
                                    Button {
                                        viewModel.selectedSpec = spec
                                    } label: {
                                        Text(spec)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.selectedSpec.isEmpty ? "Select Grade" : viewModel.selectedSpec)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(viewModel.selectedSpec.isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                        } else {
                            Text("Select Material first")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Thickness
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Thickness")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        
                        Text(viewModel.thickness)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.tertiarySystemFill))
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Quantity/Members and UoM - Side by Side
            HStack(spacing: 12) {
                // Quantity (Members for Labour)
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.selectedItemType == "Labour" ? "Members" : "Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    TextField("0", text: Binding(
                        get: { viewModel.quantity },
                        set: { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            viewModel.quantity = filtered
                        }
                    ))
                    .font(.body)
                    .fontWeight(.semibold)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .id("quantity")
                
                // UoM (Dropdown for Labour, TextField for others)
                VStack(alignment: .leading, spacing: 6) {
                    Text("UoM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    if viewModel.selectedItemType == "Labour" {
                        // Dropdown for Labour
                        Menu {
                            ForEach(DepartmentItemData.uomOptions(for: "Labour"), id: \.self) { uomOption in
                                Button {
                                    viewModel.uom = uomOption
                                } label: {
                                    HStack {
                                        Text(uomOption)
                                        if viewModel.uom == uomOption {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.uom.isEmpty ? "Select UoM" : viewModel.uom)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.uom.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                        }
                    } else {
                        // TextField for other item types
                        TextField("ton", text: $viewModel.uom)
                            .font(.body)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Unit Price (UOM + Price for Labour) and Line Amount - Side by Side
            HStack(spacing: 12) {
                // Unit Price (UOM + Price for Labour)
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.selectedItemType == "Labour" ? (viewModel.uom.isEmpty ? "UOM Price" : "\(viewModel.uom) Price") : "Unit Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    TextField("0", text: Binding(
                        get: { viewModel.unitPrice },
                        set: { newValue in
                            viewModel.unitPrice = viewModel.formatAmountInput(newValue)
                        }
                    ))
                    .font(.body)
                    .fontWeight(.semibold)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .id("unitPrice")
                
                // Line Amount
                VStack(alignment: .leading, spacing: 6) {
                    Text("Line Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Text(formatCurrency(viewModel.lineAmount))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Notes Section
    private var notesView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.caption)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
            
            TextEditor(text: $viewModel.description)
                .font(.body)
                .frame(minHeight: 80)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.descriptionError != nil ? Color.red : Color.clear, lineWidth: 1)
                )
            
            if let error = viewModel.descriptionError {
                InlineErrorMessage(message: error)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Categories Section
    private var categoriesHeader: some View {
        HStack {
            Text("Category")
//            Spacer()
//            Button(action: viewModel.addCategory) {
//                Image(systemName: "plus.circle.fill")
//                    .foregroundColor(.blue)
//                    .font(.title3)
//            }
        }
    }
    
//    private var categoriesFooter: some View {
//        Text("Add multiple categories by tapping the + button")
//            .font(.caption)
//            .foregroundColor(.secondary)
//    }
    
    private var categoriesView: some View {
        ForEach(Array(viewModel.categories.enumerated()), id: \.offset) { index, _ in
            VStack(alignment: .leading, spacing: 8) {
                // Category Dropdown
                CategorySearchableDropdown(
                    selectedCategory: Binding(
                        get: { 
                            (index >= 0 && index < viewModel.categories.count) ? viewModel.categories[index] : ""
                        },
                        set: { newValue in
                            // This binding is updated as user types, allowing custom entries
                            if index < viewModel.categories.count {
                                let trimmedValue = newValue.trimmingCharacters(in: .whitespaces)
                                if !trimmedValue.isEmpty {
                                    viewModel.categories[index] = trimmedValue
                                }
                            }
                        }
                    ),
                    searchText: Binding(
                        get: { 
                            // If category exists but search text is empty, use category
                            let category = (index >= 0 && index < viewModel.categories.count) ? viewModel.categories[index] : ""
                            return viewModel.categorySearchTexts[index] ?? category
                        },
                        set: { newValue in
                            viewModel.categorySearchTexts[index] = newValue
                            // Also update categories array if text is not empty (for validation)
                            let trimmedValue = newValue.trimmingCharacters(in: .whitespaces)
                            if !trimmedValue.isEmpty && index < viewModel.categories.count {
                                viewModel.categories[index] = trimmedValue
                            }
                        }
                    ),
                    filteredCategories: viewModel.filteredCategories(for: index),
                    index: index,
                    onSelect: { category in
                        viewModel.selectCategory(category, at: index)
                    },
                    showRemoveButton: viewModel.categories.count > 1,
                    onRemove: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.removeCategory(at: index)
                        }
                    }
                )
                
                // Show custom name field if "Misc / Other" is selected
                if index >= 0 && index < viewModel.categories.count && viewModel.categories[index] == "Misc / Other (notes required)" {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Category Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("Enter custom category name", text: Binding(
                            get: { viewModel.categoryCustomNames[index] ?? "" },
                            set: { newValue in
                                viewModel.setCategoryCustomName(newValue, at: index)
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke((viewModel.categoryError(at: index)?.contains("Custom") ?? false) ? Color.red : Color.clear, lineWidth: 1)
                        )
                        
                        if let error = viewModel.categoryError(at: index), error.contains("Custom") {
                            InlineErrorMessage(message: error)
                        }
                    }
                    .id("category_\(index)_custom")
                    .padding(.leading, 8)
                    .padding(.top, 4)
                }
                
                if let error = viewModel.categoryError(at: index), !error.contains("Custom") {
                    InlineErrorMessage(message: error)
                }
            }
            .id("category_\(index)")
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Payment Mode
    private var paymentModeView: some View {
        VStack(spacing: 12) {
            ForEach(PaymentMode.allCases, id: \.self) { mode in
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedPaymentMode = mode
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.selectedPaymentMode == mode ? "circle.inset.filled" : "circle")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            HStack(spacing: 8) {
                                Image(systemName: mode.icon)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                Text(mode.rawValue)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Receipt Section
    private var receiptView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let attachmentName = viewModel.attachmentName {
                // Show attached file
                HStack(spacing: 12) {
                    // File info - not clickable
                    HStack {
                        Image(systemName: fileIcon(for: attachmentName))
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(attachmentName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text("Tap preview to view")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Preview button - separate icon button
                    Button(action: {
                        HapticManager.selection()
                        showingFileViewer = true
                    }) {
                        Image(systemName: "eye.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    // Remove button - separate action
                    Button(action: {
                        HapticManager.selection()
                        withAnimation(.easeInOut) {
                            viewModel.removeAttachment()
                        }
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Add receipt button
                Button(action: {
                    viewModel.showingAttachmentOptions = true
                }) {
                    HStack {
                        Image(systemName: "paperclip")
                            .font(.title3)
                        Text("Add Receipt")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(UIColor.tertiarySystemFill))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.attachmentError != nil ? Color.red : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Upload progress
            if viewModel.isUploading {
                VStack(spacing: 8) {
                    ProgressView(value: viewModel.uploadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                    Text("Uploading... \(Int(viewModel.uploadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Error message
            if let error = viewModel.attachmentError {
                InlineErrorMessage(message: error)
            }
        }
        .id("attachment")
        .padding(.vertical, 4)
    }
    
    // MARK: - Payment Proof Section
    private var paymentProofView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let paymentProofName = viewModel.paymentProofName {
                // Show attached file
                HStack(spacing: 12) {
                    // File info - not clickable
                    HStack {
                        Image(systemName: fileIcon(for: paymentProofName))
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(paymentProofName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text("Tap preview to view")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Preview button - separate icon button
                    Button(action: {
                        HapticManager.selection()
                        showingPaymentProofFileViewer = true
                    }) {
                        Image(systemName: "eye.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    // Remove button - separate action
                    Button(action: {
                        HapticManager.selection()
                        withAnimation(.easeInOut) {
                            viewModel.removePaymentProof()
                        }
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 44, height: 44)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // Add payment proof button
                Button(action: {
                    viewModel.showingPaymentProofOptions = true
                }) {
                    HStack {
                        Image(systemName: "paperclip")
                            .font(.title3)
                        Text("Add Payment Proof")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color(UIColor.tertiarySystemFill))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.paymentProofError != nil ? Color.red : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Upload progress
            if viewModel.isUploadingPaymentProof {
                VStack(spacing: 8) {
                    ProgressView(value: viewModel.paymentProofUploadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                    Text("Uploading... \(Int(viewModel.paymentProofUploadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Error message
            if let error = viewModel.paymentProofError {
                InlineErrorMessage(message: error)
            }
        }
        .id("paymentProof")
        .padding(.vertical, 4)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: {
            HapticManager.impact(.medium)
            // Validate and find first invalid field before submitting
            if let firstInvalidField = viewModel.validateAndFindFirstInvalidField() {
                viewModel.firstInvalidFieldId = firstInvalidField
                HapticManager.notification(.error)
            } else {
                // Form is valid, proceed with submission
                viewModel.submitExpense()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Submit for Approval")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isFormValid ? Color.blue : Color.blue.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading || !viewModel.isFormValid)
        .opacity(viewModel.isFormValid ? 1.0 : 0.6)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    let allowedTypes: [UTType]
    let onDocumentPicked: (Result<[URL], Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        // Enable access to files outside the app's sandbox
        picker.shouldShowFileExtensions = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // URLs are already accessible, no need for security-scoped resource handling here
            // The ViewModel will handle copying to a temporary location
            parent.onDocumentPicked(.success(urls))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle cancellation if needed
        }
    }
}

// MARK: - Expense Image Picker
struct ExpenseImagePicker: UIViewControllerRepresentable {
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
        let parent: ExpenseImagePicker
        
        init(_ parent: ExpenseImagePicker) {
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

// MARK: - Expense Camera Picker
struct ExpenseCameraPicker: UIViewControllerRepresentable {
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
        let parent: ExpenseCameraPicker
        
        init(_ parent: ExpenseCameraPicker) {
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

// MARK: - Category Searchable Dropdown
struct CategorySearchableDropdown: View {
    @Binding var selectedCategory: String
    @Binding var searchText: String
    let filteredCategories: [String]
    let index: Int
    let onSelect: (String) -> Void
    let showRemoveButton: Bool
    let onRemove: () -> Void
    @State private var showDropdown = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // Always show text field for both search and entry
                TextField("Search or enter category", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        showDropdown = true
                    }
                    .onChange(of: searchText) { newValue in
                        // Show dropdown when typing (if there are matches)
                        if !newValue.isEmpty {
                            showDropdown = true
                        } else {
                            showDropdown = false
                        }
                    }
                    .onSubmit {
                        // When user presses return/done, accept the typed text as the category
                        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
                        if !trimmedText.isEmpty {
                            onSelect(trimmedText)
                            showDropdown = false
                            isTextFieldFocused = false
                        }
                    }
                    .onChange(of: isTextFieldFocused) { focused in
                        if !focused {
                            // When text field loses focus, accept the typed text if it's not empty
                            let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
                            if !trimmedText.isEmpty {
                                onSelect(trimmedText)
                            }
                            // Hide dropdown after a short delay to allow selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showDropdown = false
                            }
                        } else {
                            // Show dropdown when focused (if there are matches)
                            if !searchText.isEmpty {
                                showDropdown = true
                            }
                        }
                    }
                
                if showRemoveButton {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                }
            }
            
            // Dropdown List - Show matching suggestions
            if showDropdown && isTextFieldFocused && !filteredCategories.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredCategories, id: \.self) { category in
                            Button(action: {
                                onSelect(category)
                                searchText = category
                                showDropdown = false
                                isTextFieldFocused = false
                            }) {
                                HStack {
                                    Text(category)
                                        .foregroundColor(.primary)
                                        .font(.subheadline)
                                    Spacer()
                                    if selectedCategory == category {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            // Initialize search text with selected category if it exists
            if !selectedCategory.isEmpty && searchText.isEmpty {
                searchText = selectedCategory
            }
        }
        .onChange(of: selectedCategory) { newValue in
            // Sync search text when category is selected from dropdown
            if !newValue.isEmpty && searchText != newValue {
                searchText = newValue
            }
        }
    }
}

// MARK: - BusinessHead Approval Message View
struct BusinessHeadApprovalMessageView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 14, weight: .medium))
            
            Text(message)
                .font(DesignSystem.Typography.caption1)
                .foregroundColor(.orange)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.extraSmall)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.small)
        .padding(.top, DesignSystem.Spacing.extraSmall)
    }
}

// MARK: - Preview
#Preview {
    AddExpenseView(project: Project.sampleData[0])
} 
