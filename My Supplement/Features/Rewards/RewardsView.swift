//
//  RewardsView.swift
//  My Supplement
//
//  Gamification and rewards tracking
//

import SwiftUI

struct RewardsView: View {
    @State private var totalCoins: Int = 0
    @State private var earnedToday: Int = 0
    @State private var streak: Int = 0
    @State private var supplementsTaken: Int = 0
    @State private var quizzesCompleted: Int = 0
    @State private var achievements: [Achievement] = []
    @State private var recentActivity: [RewardTransaction] = []
    
    private var dataManager: DataManager { DataManager.shared }
    
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
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        let summary = dataManager.getOrCreateRewardsSummary()
        totalCoins = summary.availableCoins
        streak = summary.currentStreak
        supplementsTaken = summary.supplementsTaken
        quizzesCompleted = summary.quizzesCompleted
        earnedToday = dataManager.getEarnedToday()
        recentActivity = dataManager.getRewardTransactions(limit: 10)
        
        // Build achievements from summary
        achievements = [
            Achievement(name: "First Step", icon: "figure.walk", color: "4CAF50", isUnlocked: summary.hasFirstStepAchievement),
            Achievement(name: "Week Warrior", icon: "flame.fill", color: "FF9800", isUnlocked: summary.hasWeekWarriorAchievement),
            Achievement(name: "Quiz Master", icon: "brain.head.profile", color: "9C27B0", isUnlocked: summary.hasQuizMasterAchievement),
            Achievement(name: "Supplement Pro", icon: "pills.fill", color: "2196F3", isUnlocked: summary.hasSupplementProAchievement),
            Achievement(name: "30 Day Streak", icon: "calendar", color: "F44336", isUnlocked: summary.has30DayStreakAchievement),
            Achievement(name: "Health Guru", icon: "heart.fill", color: "E91E63", isUnlocked: summary.hasHealthGuruAchievement),
        ]
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
                value: "\(supplementsTaken)",
                icon: "pills.fill",
                color: .green
            )
            RewardStatCard(
                title: "Quizzes Completed",
                value: "\(quizzesCompleted)",
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
            
            if recentActivity.isEmpty {
                Text("No activity yet. Take supplements and complete quizzes to earn coins!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(recentActivity.prefix(5)) { transaction in
                        RewardHistoryRow(
                            icon: iconForType(transaction.type),
                            title: transaction.title,
                            coins: transaction.coins,
                            time: timeAgo(from: transaction.timestamp)
                        )
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "supplement_taken": return "pills.fill"
        case "quiz_completed": return "questionmark.circle.fill"
        case "streak_bonus": return "flame.fill"
        case "achievement": return "star.fill"
        default: return "star.circle.fill"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) min\(minutes == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
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
