//
//  HomeView.swift
//  My Supplement
//
//  Main home screen with calendar and daily tracking
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store : SupplementStore
    @State private var selectedDate = Date()
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var totalCoins: Int = 0
    @State private var currentStreak: Int = 0
    @State private var takenToday: Int = 0
    
    private let calendar = Calendar.current
    private var dataManager: DataManager { DataManager.shared }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Calendar Week View
                calendarSection
                
                // Today's Supplements
                supplementsSection
                
                // Quick Stats
                statsSection
                
                // Did You Know
                didYouKnowSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("My Supplement")
        .toast(isShowing: $showToast, message: toastMessage, type: .success)
        .onAppear {
            refreshStats()
        }
    }
    
    private func refreshStats() {
        let summary = dataManager.getOrCreateRewardsSummary()
        totalCoins = summary.availableCoins
        currentStreak = summary.currentStreak
        
        let todayStats = dataManager.getTodayStats()
        takenToday = todayStats.taken
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello! 👋")
                    .font(.title2.weight(.semibold))
                Text(dateFormatter.string(from: selectedDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Coins indicator
            HStack(spacing: 6) {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(totalCoins)")
                    .font(.headline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appCardBackground)
            .cornerRadius(20)
        }
    }
    
    // MARK: - Calendar
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { date in
                    DayButton(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasSupplements: !store.supplements(for: date).isEmpty
                    ) {
                        withAnimation(.spring()) {
                            selectedDate = date
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Supplements Grid
    private var supplementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Take Your Supplements")
                    .font(.headline)
                Spacer()
                NavigationLink(value: HomeFlow.supplementList) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.appPrimary)
                }
            }
            
            let todaySupplements = store.supplements(for: selectedDate)
            
            if todaySupplements.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(todaySupplements) { supplement in
                        SupplementCard(
                            supplement: supplement,
                            isTaken: store.isTaken(supplement.id, for: selectedDate)
                        ) {
                            let coinsEarned = dataManager.markSupplementTaken(
                                supplement.id,
                                supplementName: supplement.name,
                                for: selectedDate
                            )
                            store.markAsTaken(supplement.id, for: selectedDate)
                            
                            if coinsEarned > 0 {
                                toastMessage = "\(supplement.name) marked as taken! +\(coinsEarned) coins"
                                showToast = true
                                refreshStats()
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "pills")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No supplements scheduled")
                .font(.subheadline)
                .foregroundColor(.secondary)
            NavigationLink(value: HomeFlow.allSupplements) {
                Text("Add Favorites")
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(title: "Taken Today", value: "\(takenToday)", icon: "checkmark.circle.fill", color: .green)
            StatCard(title: "Streak", value: "\(currentStreak) days", icon: "flame.fill", color: .orange)
        }
    }
    
    // MARK: - Did You Know
    private var didYouKnowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Did You Know?")
                    .font(.headline)
            }
            
            Text("Vitamin D is best absorbed when taken with a fat-containing meal. Try taking it with breakfast!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }
    
    // MARK: - Helpers
    private var weekDays: [Date] {
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
}

// MARK: - Day Button
struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let hasSupplements: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .secondary)
                
                Text(dayNumber)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if hasSupplements {
                    Circle()
                        .fill(isSelected ? .white : .appPrimary)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.appPrimary : Color.clear)
            .cornerRadius(12)
        }
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// MARK: - Supplement Card
struct SupplementCard: View {
    let supplement: Supplement
    let isTaken: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: supplement.category.icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: supplement.category.color))
                    Spacer()
                    if isTaken {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Text(supplement.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(supplement.timingDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(isTaken ? Color.green.opacity(0.1) : Color.appCardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTaken ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title2.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
