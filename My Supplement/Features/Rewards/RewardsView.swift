//
//  RewardsView.swift
//  My Supplement
//
//  Gamification and rewards tracking
//

import SwiftUI

struct RewardsView: View {
    @State private var totalCoins: Int = 150
    @State private var earnedToday: Int = 25
    @State private var streak: Int = 7
    @State private var achievements: [Achievement] = Achievement.samples
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Coins Card
                coinsCard
                
                // Stats Grid
                statsGrid
                
                // Achievements
                achievementsSection
                
                // History
                historySection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Rewards")
    }
    
    // MARK: - Coins Card
    private var coinsCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .orange.opacity(0.4), radius: 20)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("\(totalCoins)")
                    .font(.system(size: 42, weight: .bold))
                Text("Total Coins")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                MiniStat(icon: "plus.circle.fill", value: "+\(earnedToday)", label: "Today", color: .green)
                MiniStat(icon: "flame.fill", value: "\(streak)", label: "Day Streak", color: .orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        HStack(spacing: 12) {
            RewardStatCard(
                title: "Supplements Taken",
                value: "42",
                icon: "pills.fill",
                color: .green
            )
            RewardStatCard(
                title: "Quizzes Completed",
                value: "8",
                icon: "checkmark.circle.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Achievements
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                Spacer()
                Text("\(achievements.filter { $0.isUnlocked }.count)/\(achievements.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(achievements) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - History
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            VStack(spacing: 8) {
                RewardHistoryRow(
                    icon: "pills.fill",
                    title: "Took Vitamin C",
                    coins: 5,
                    time: "2 hours ago"
                )
                RewardHistoryRow(
                    icon: "questionmark.circle.fill",
                    title: "Quiz: 4/5 correct",
                    coins: 40,
                    time: "Yesterday"
                )
                RewardHistoryRow(
                    icon: "flame.fill",
                    title: "7-day streak bonus!",
                    coins: 50,
                    time: "Yesterday"
                )
            }
        }
        .cardStyle()
    }
}

// MARK: - Supporting Views
struct MiniStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.subheadline.weight(.bold))
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct RewardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title.weight(.bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color(hex: achievement.color).opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? Color(hex: achievement.color) : .gray)
            }
            
            Text(achievement.name)
                .font(.caption2)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

struct RewardHistoryRow: View {
    let icon: String
    let title: String
    let coins: Int
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("+\(coins)")
                .font(.subheadline.weight(.bold))
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let isUnlocked: Bool
    
    static var samples: [Achievement] {
        [
            Achievement(name: "First Step", icon: "figure.walk", color: "4CAF50", isUnlocked: true),
            Achievement(name: "Week Warrior", icon: "flame.fill", color: "FF9800", isUnlocked: true),
            Achievement(name: "Quiz Master", icon: "brain.head.profile", color: "9C27B0", isUnlocked: true),
            Achievement(name: "Supplement Pro", icon: "pills.fill", color: "2196F3", isUnlocked: false),
            Achievement(name: "30 Day Streak", icon: "calendar", color: "F44336", isUnlocked: false),
            Achievement(name: "Health Guru", icon: "heart.fill", color: "E91E63", isUnlocked: false),
        ]
    }
}

#Preview {
    NavigationStack {
        RewardsView()
    }
}
