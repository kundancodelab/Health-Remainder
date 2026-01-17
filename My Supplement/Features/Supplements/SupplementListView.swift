//
//  SupplementListView.swift
//  My Supplement
//
//  Browse and search all supplements
//

import SwiftUI

struct SupplementListView: View {
    @State private var store = SupplementStore()
    @State private var searchText = ""
    @State private var selectedCategory: SupplementCategory? = nil
    
    var filteredSupplements: [Supplement] {
        var result = store.supplements
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Category Filter
                categoryFilter
                
                // Supplements List
                LazyVStack(spacing: 12) {
                    ForEach(filteredSupplements) { supplement in
                        NavigationLink(value: supplement) {
                            SupplementRowView(supplement: supplement)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Supplements")
        .searchable(text: $searchText, prompt: "Search supplements...")
        .navigationDestination(for: Supplement.self) { supplement in
            SupplementDetailView(supplement: supplement)
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    color: .appPrimary
                ) {
                    withAnimation { selectedCategory = nil }
                }
                
                ForEach(SupplementCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        color: Color(hex: category.color)
                    ) {
                        withAnimation { selectedCategory = category }
                    }
                }
            }
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? color : color.opacity(0.15))
            .cornerRadius(20)
        }
    }
}

// MARK: - Supplement Row
struct SupplementRowView: View {
    let supplement: Supplement
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: supplement.category.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: supplement.category.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: supplement.category.color))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(supplement.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(supplement.benefits.prefix(2).joined(separator: " • "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label(supplement.timingDisplay, systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if supplement.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color.appCardBackground)
        .cornerRadius(14)
    }
}

#Preview {
    NavigationStack {
        SupplementListView()
    }
}
