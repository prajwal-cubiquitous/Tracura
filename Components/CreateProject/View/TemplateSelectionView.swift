//
//  TemplateSelectionView.swift
//  Tracura
//
//  Created for template selection
//

import SwiftUI

struct TemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelectTemplate: (ProjectTemplate) -> Void
    let onCreateNew: () -> Void
    
    @State private var searchText: String = ""
    
    private var filteredTemplates: [ProjectTemplate] {
        if searchText.isEmpty {
            return ProjectTemplate.predefinedTemplates
        }
        return ProjectTemplate.predefinedTemplates.filter { template in
            template.name.localizedCaseInsensitiveContains(searchText) ||
            template.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                if !ProjectTemplate.predefinedTemplates.isEmpty {
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
                }
                
                // Templates List
                if filteredTemplates.isEmpty {
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
                            ForEach(filteredTemplates) { template in
                                TemplateCardView(template: template) {
                                    HapticManager.selection()
                                    onSelectTemplate(template)
                                    dismiss()
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
    let template: ProjectTemplate
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Header
                HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
                    // Icon
                    Image(systemName: template.icon)
                        .font(.system(size: 32))
                        .foregroundColor(.accentColor)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                        )
                    
                    // Title and Description
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                        Text(template.name)
                            .font(DesignSystem.Typography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(template.description)
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
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(template.phases.count) Phase\(template.phases.count == 1 ? "" : "s")")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(.secondary)
                    }
                    
                    // Departments Count
                    let totalDepartments = template.phases.reduce(0) { $0 + $1.departments.count }
                    HStack(spacing: DesignSystem.Spacing.small) {
                        Image(systemName: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(totalDepartments) Department\(totalDepartments == 1 ? "" : "s")")
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

