//
//  TemplateSelectionView.swift
//  Tracura
//
//  Created for template selection
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: FirebaseAuthService
    let onSelectTemplate: (ProjectTemplate) -> Void
    let onCreateNew: () -> Void
    
    @State private var searchText: String = ""
    @State private var businessType: String? = nil
    @State private var isLoadingBusinessType: Bool = true
    
    private var filteredTemplates: [TemplateDisplayItem] {
        return TemplateDataStore.searchTemplates(query: searchText, businessType: businessType)
    }
    
    private func fetchBusinessType() async {
        isLoadingBusinessType = true
        do {
            // Get current customer ID
            let customerId: String
            if let currentUser = Auth.auth().currentUser {
                // Check if user logged in via email (admin) or phone
                if let phoneNumber = currentUser.phoneNumber {
                    // OTP user - get ownerID from users collection
                    let cleanPhone = phoneNumber.replacingOccurrences(of: "+91", with: "")
                    let userDoc = try await Firestore.firestore()
                        .collection("users")
                        .document(cleanPhone)
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
            } else {
                print("⚠️ TemplateSelectionView: No current user found")
                await MainActor.run {
                    isLoadingBusinessType = false
                }
                return
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
                    print("✅ TemplateSelectionView: Fetched businessType: \(businessTypeValue)")
                    isLoadingBusinessType = false
                }
            } else {
                print("⚠️ TemplateSelectionView: businessType not found in customer document")
                await MainActor.run {
                    isLoadingBusinessType = false
                }
            }
        } catch {
            print("❌ TemplateSelectionView: Error fetching businessType: \(error.localizedDescription)")
            await MainActor.run {
                isLoadingBusinessType = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search templates...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Templates List
                if isLoadingBusinessType {
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading templates...")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredTemplates.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Spacer()
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.6))
                            .symbolRenderingMode(.hierarchical)
                        
                        Text("No Templates Found")
                            .font(DesignSystem.Typography.title2)
                            .foregroundColor(.primary)
                        
                        Text("Try adjusting your search")
                            .font(DesignSystem.Typography.callout)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach(filteredTemplates) { templateItem in
                                TemplateCardView(templateItem: templateItem) {
                                    HapticManager.selection()
                                    // Get the full ProjectTemplate and pass it to the callback
                                    if let projectTemplate = templateItem.projectTemplate {
                                        print("✅ TemplateSelectionView: Selected template '\(templateItem.id)' with \(projectTemplate.phases.count) phases")
                                        onSelectTemplate(projectTemplate)
                                    dismiss()
                                    } else {
                                        print("❌ TemplateSelectionView: Failed to load template '\(templateItem.id)' - projectTemplate is nil")
                                        // Show error or fallback behavior
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Template")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await fetchBusinessType()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create New") {
                        HapticManager.selection()
                        onCreateNew()
                        dismiss()
                    }
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Template Card View
struct TemplateCardView: View {
    let templateItem: TemplateDisplayItem
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Header
                HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
                    // Icon
                    Image(systemName: templateItem.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                        )
                    
                    // Title and Description
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                        Text(templateItem.title)
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(templateItem.description)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Template Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    // Phases Count
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(templateItem.phasesCount) Phase\(templateItem.phasesCount == 1 ? "" : "s")")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(.secondary)
                    }
                    
                    // Departments Count
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(templateItem.departmentsCount) Department\(templateItem.departmentsCount == 1 ? "" : "s")")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct TemplateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateSelectionView(
            onSelectTemplate: { _ in },
            onCreateNew: { }
        )
    }
}

