//
//  SupplementDetailView.swift
//  My Supplement
//
//  Detailed view for a single supplement
//

import SwiftUI

struct SupplementDetailView: View {
    let supplement: Supplement
    @State private var isFavorite: Bool = false
    @State private var showToast = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                headerCard
                
                // Benefits Section
                sectionCard(title: "Benefits", icon: "checkmark.seal.fill", color: .green) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(supplement.benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(benefit)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Dosage & Timing
                sectionCard(title: "Dosage & Timing", icon: "clock.fill", color: .blue) {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Recommended", value: supplement.dosage.isEmpty ? "Consult label" : supplement.dosage)
                        InfoRow(label: "Best Time", value: supplement.timingDisplay)
                        InfoRow(label: "Meal Timing", value: supplement.mealTimingDisplay)
                    }
                }
                
                // Synergies
                if !supplement.synergies.isEmpty {
                    sectionCard(title: "Works Well With", icon: "link", color: .purple) {
                        FlowLayout(spacing: 8) {
                            ForEach(supplement.synergies, id: \.self) { synergy in
                                TagView(text: synergy, color: .purple)
                            }
                        }
                    }
                }
                
                // Incompatibilities
                if !supplement.incompatibleWith.isEmpty {
                    sectionCard(title: "Avoid With", icon: "exclamationmark.triangle.fill", color: .orange) {
                        FlowLayout(spacing: 8) {
                            ForEach(supplement.incompatibleWith, id: \.self) { item in
                                TagView(text: item, color: .orange)
                            }
                        }
                    }
                }
                
                // Side Effects
                if !supplement.sideEffects.isEmpty {
                    sectionCard(title: "Possible Side Effects", icon: "info.circle.fill", color: .red) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(supplement.sideEffects, id: \.self) { effect in
                                HStack(alignment: .top, spacing: 8) {
                                    Circle()
                                        .fill(Color.red.opacity(0.5))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    Text(effect)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Food Sources
                if !supplement.foodSources.isEmpty {
                    sectionCard(title: "Food Sources", icon: "leaf.fill", color: .green) {
                        FlowLayout(spacing: 8) {
                            ForEach(supplement.foodSources, id: \.self) { food in
                                TagView(text: food, color: .green)
                            }
                        }
                    }
                }
                
                // Special Notes
                if !supplement.specialNotes.isEmpty {
                    sectionCard(title: "Special Notes", icon: "note.text", color: .gray) {
                        Text(supplement.specialNotes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle(supplement.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isFavorite.toggle()
                    showToast = true
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .gray)
                }
            }
        }
        .toast(isShowing: $showToast, message: isFavorite ? "Added to favorites!" : "Removed from favorites", type: isFavorite ? .success : .info)
        .onAppear {
            isFavorite = supplement.isFavorite
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: supplement.category.color).opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: supplement.category.icon)
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: supplement.category.color))
            }
            
            VStack(spacing: 4) {
                Text(supplement.name)
                    .font(.title2.weight(.bold))
                Text(supplement.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(supplement.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    // MARK: - Section Card Builder
    @ViewBuilder
    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            content()
        }
        .cardStyle()
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
        }
    }
}

// MARK: - Tag View
struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                maxHeight = max(maxHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: width, height: y + maxHeight)
        }
    }
}

#Preview {
    NavigationStack {
        SupplementDetailView(supplement: Supplement(
            id: "test",
            name: "Vitamin C",
            description: "A powerful antioxidant that supports immune function.",
            dosage: "500-1000mg daily",
            benefits: ["Immune support", "Antioxidant", "Collagen production"],
            specialNotes: "Take with food",
            synergies: ["Iron", "Zinc"],
            incompatibleWith: ["High alcohol"],
            sideEffects: ["May cause digestive upset at high doses"],
            foodSources: ["Oranges", "Bell peppers", "Kiwi"],
            foodImages: []
        ))
    }
}
