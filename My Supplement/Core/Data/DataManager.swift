//
//  DataManager.swift
//  My Supplement
//
//  SwiftData manager for CRUD operations
//

import Foundation
import SwiftData

@MainActor
@Observable
final class DataManager {
    static let shared = DataManager()
    
    var modelContainer: ModelContainer?
    var modelContext: ModelContext?
    
    private init() {}
    
    // MARK: - Setup
    func setup(with container: ModelContainer) {
        self.modelContainer = container
        self.modelContext = container.mainContext
    }
    
    // MARK: - User Operations
    func getCurrentUser() -> UserData? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<UserData>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try? context.fetch(descriptor).first
    }
    
    func createOrUpdateUser(
        id: String,
        userName: String,
        email: String,
        age: Int? = nil,
        gender: String? = nil,
        lifeStage: String? = nil
    ) {
        guard let context = modelContext else { return }
        
        // Check if user exists
        let descriptor = FetchDescriptor<UserData>(
            predicate: #Predicate { $0.id == id }
        )
        
        if let existingUser = try? context.fetch(descriptor).first {
            existingUser.userName = userName
            existingUser.email = email
            existingUser.age = age
            existingUser.gender = gender
            existingUser.lifeStage = lifeStage
            existingUser.updatedAt = Date()
        } else {
            let user = UserData(
                id: id,
                userName: userName,
                email: email,
                age: age,
                gender: gender,
                lifeStage: lifeStage
            )
            context.insert(user)
        }
        
        try? context.save()
    }
    
    // MARK: - Daily Record Operations
    func getDailyRecords(for date: Date) -> [DailyRecord] {
        guard let context = modelContext else { return [] }
        let dateKey = DailyRecord.dateKey(for: date)
        
        let descriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { record in
                record.id.contains(dateKey)
            },
            sortBy: [SortDescriptor(\.supplementName)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getOrCreateDailyRecord(supplementId: String, supplementName: String, for date: Date) -> DailyRecord {
        guard let context = modelContext else {
            return DailyRecord(supplementId: supplementId, supplementName: supplementName, date: date)
        }
        
        let recordId = "\(supplementId)_\(DailyRecord.dateKey(for: date))"
        let descriptor = FetchDescriptor<DailyRecord>(
            predicate: #Predicate { $0.id == recordId }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        let record = DailyRecord(supplementId: supplementId, supplementName: supplementName, date: date)
        context.insert(record)
        try? context.save()
        return record
    }
    
    func markSupplementTaken(_ supplementId: String, supplementName: String, for date: Date) -> Int {
        guard let context = modelContext else { return 0 }
        
        let record = getOrCreateDailyRecord(supplementId: supplementId, supplementName: supplementName, for: date)
        
        if !record.isTaken {
            record.isTaken = true
            record.takenAt = Date()
            record.coinsAwarded = 5
            
            // Award coins
            addRewardTransaction(
                type: "supplement_taken",
                coins: 5,
                title: "Took \(supplementName)",
                relatedId: supplementId
            )
            
            // Update rewards summary
            updateRewardsSummary(coinsToAdd: 5, supplementTaken: true)
            
            try? context.save()
            return 5
        }
        
        return 0
    }
    
    func toggleFavorite(_ supplementId: String, supplementName: String, for date: Date? = nil) {
        guard let context = modelContext else { return }
        
        // Toggle in favorites list
        let favoriteId = "local_\(supplementId)"
        let descriptor = FetchDescriptor<FavoriteSupplement>(
            predicate: #Predicate { $0.id == favoriteId }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
        } else {
            let favorite = FavoriteSupplement(supplementId: supplementId)
            context.insert(favorite)
        }
        
        try? context.save()
    }
    
    func isFavorite(_ supplementId: String) -> Bool {
        guard let context = modelContext else { return false }
        
        let favoriteId = "local_\(supplementId)"
        let descriptor = FetchDescriptor<FavoriteSupplement>(
            predicate: #Predicate { $0.id == favoriteId }
        )
        
        return (try? context.fetch(descriptor).first) != nil
    }
    
    func getFavoriteSupplements() -> [FavoriteSupplement] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<FavoriteSupplement>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Quiz Operations
    func saveQuizResult(
        totalQuestions: Int,
        correctCount: Int,
        incorrectCount: Int,
        coinsEarned: Int,
        difficulty: String? = nil
    ) {
        guard let context = modelContext else { return }
        
        let record = QuizHistoryRecord(
            totalQuestions: totalQuestions,
            correctCount: correctCount,
            incorrectCount: incorrectCount,
            coinsEarned: coinsEarned,
            difficulty: difficulty
        )
        context.insert(record)
        
        // Award coins
        addRewardTransaction(
            type: "quiz_completed",
            coins: coinsEarned,
            title: "Quiz: \(correctCount)/\(totalQuestions) correct"
        )
        
        // Update rewards summary
        updateRewardsSummary(coinsToAdd: coinsEarned, quizCompleted: true)
        
        try? context.save()
    }
    
    func getQuizHistory(limit: Int = 10) -> [QuizHistoryRecord] {
        guard let context = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<QuizHistoryRecord>(
            sortBy: [SortDescriptor(\.attemptDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Rewards Operations
    func addRewardTransaction(type: String, coins: Int, title: String, relatedId: String? = nil) {
        guard let context = modelContext else { return }
        
        let transaction = RewardTransaction(
            type: type,
            coins: coins,
            title: title,
            relatedId: relatedId
        )
        context.insert(transaction)
        try? context.save()
    }
    
    func getRewardTransactions(limit: Int = 20) -> [RewardTransaction] {
        guard let context = modelContext else { return [] }
        
        var descriptor = FetchDescriptor<RewardTransaction>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getOrCreateRewardsSummary() -> UserRewardsSummary {
        guard let context = modelContext else {
            return UserRewardsSummary(userId: "local")
        }
        
        let userId = "local"
        let descriptor = FetchDescriptor<UserRewardsSummary>(
            predicate: #Predicate { $0.userId == userId }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        
        let summary = UserRewardsSummary(userId: userId)
        context.insert(summary)
        try? context.save()
        return summary
    }
    
    func updateRewardsSummary(
        coinsToAdd: Int = 0,
        supplementTaken: Bool = false,
        quizCompleted: Bool = false
    ) {
        guard let context = modelContext else { return }
        
        let summary = getOrCreateRewardsSummary()
        summary.totalCoinsEarned += coinsToAdd
        
        if supplementTaken {
            summary.supplementsTaken += 1
            updateStreak(for: summary)
        }
        
        if quizCompleted {
            summary.quizzesCompleted += 1
        }
        
        summary.checkAndUpdateAchievements()
        try? context.save()
    }
    
    private func updateStreak(for summary: UserRewardsSummary) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastActivity = summary.lastActivityDate {
            let lastActivityDay = Calendar.current.startOfDay(for: lastActivity)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastActivityDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                // Same day, no streak update needed
            } else if daysDifference == 1 {
                // Consecutive day, increase streak
                summary.currentStreak += 1
                if summary.currentStreak > summary.longestStreak {
                    summary.longestStreak = summary.currentStreak
                }
                
                // Check for streak bonuses
                if summary.currentStreak == 7 {
                    addRewardTransaction(type: "streak_bonus", coins: 50, title: "7-day streak bonus!")
                    summary.totalCoinsEarned += 50
                } else if summary.currentStreak == 30 {
                    addRewardTransaction(type: "streak_bonus", coins: 200, title: "30-day streak bonus!")
                    summary.totalCoinsEarned += 200
                }
            } else {
                // Streak broken
                summary.currentStreak = 1
            }
        } else {
            // First activity
            summary.currentStreak = 1
        }
        
        summary.lastActivityDate = today
    }
    
    // MARK: - Stats
    func getTodayStats() -> (taken: Int, total: Int) {
        let records = getDailyRecords(for: Date())
        let taken = records.filter { $0.isTaken }.count
        return (taken, records.count)
    }
    
    func getEarnedToday() -> Int {
        guard let context = modelContext else { return 0 }
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<RewardTransaction>(
            predicate: #Predicate { tx in
                tx.timestamp >= today && tx.timestamp < tomorrow
            }
        )
        
        let transactions = (try? context.fetch(descriptor)) ?? []
        return transactions.reduce(0) { $0 + $1.coins }
    }
}
