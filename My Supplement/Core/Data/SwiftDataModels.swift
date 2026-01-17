//
//  SwiftDataModels.swift
//  My Supplement
//
//  SwiftData persistent models for the app
//

import Foundation
import SwiftData

// MARK: - User Data Model
@Model
final class UserData {
    @Attribute(.unique) var id: String
    var userName: String
    var email: String
    var age: Int?
    var weight: Double?
    var gender: String?
    var lifeStage: String?
    var profilePicData: Data?
    var isEmailVerified: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Preferences
    var notificationsEnabled: Bool
    var reminderTime: Date?
    var language: String
    
    init(
        id: String = UUID().uuidString,
        userName: String,
        email: String,
        age: Int? = nil,
        weight: Double? = nil,
        gender: String? = nil,
        lifeStage: String? = nil,
        isEmailVerified: Bool = false
    ) {
        self.id = id
        self.userName = userName
        self.email = email
        self.age = age
        self.weight = weight
        self.gender = gender
        self.lifeStage = lifeStage
        self.isEmailVerified = isEmailVerified
        self.createdAt = Date()
        self.updatedAt = Date()
        self.notificationsEnabled = true
        self.language = "English"
    }
    
    var genderEnum: Gender? {
        guard let gender = gender else { return nil }
        return Gender(rawValue: gender)
    }
    
    var lifeStageEnum: LifeStage? {
        guard let lifeStage = lifeStage else { return nil }
        return LifeStage(rawValue: lifeStage)
    }
}

// MARK: - Daily Supplement Record
@Model
final class DailyRecord {
    @Attribute(.unique) var id: String
    var supplementId: String
    var supplementName: String
    var date: Date
    var isTaken: Bool
    var isFavorite: Bool
    var userId: String?
    var coinsAwarded: Int
    var takenAt: Date?
    
    init(
        supplementId: String,
        supplementName: String,
        date: Date,
        isTaken: Bool = false,
        isFavorite: Bool = true,
        userId: String? = nil
    ) {
        self.id = "\(supplementId)_\(Self.dateKey(for: date))"
        self.supplementId = supplementId
        self.supplementName = supplementName
        self.date = date
        self.isTaken = isTaken
        self.isFavorite = isFavorite
        self.userId = userId
        self.coinsAwarded = 0
    }
    
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Quiz History
@Model
final class QuizHistoryRecord {
    @Attribute(.unique) var id: String
    var userId: String?
    var attemptDate: Date
    var totalQuestions: Int
    var correctCount: Int
    var incorrectCount: Int
    var coinsEarned: Int
    var difficulty: String?
    
    init(
        userId: String? = nil,
        totalQuestions: Int,
        correctCount: Int,
        incorrectCount: Int,
        coinsEarned: Int,
        difficulty: String? = nil
    ) {
        self.id = UUID().uuidString
        self.userId = userId
        self.attemptDate = Date()
        self.totalQuestions = totalQuestions
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
        self.coinsEarned = coinsEarned
        self.difficulty = difficulty
    }
    
    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions) * 100
    }
}

// MARK: - Reward Transaction
@Model
final class RewardTransaction {
    @Attribute(.unique) var id: String
    var userId: String?
    var type: String // "supplement_taken", "quiz_completed", "streak_bonus", "achievement"
    var coins: Int
    var title: String
    var timestamp: Date
    var relatedId: String? // supplementId or quizId
    
    init(
        userId: String? = nil,
        type: String,
        coins: Int,
        title: String,
        relatedId: String? = nil
    ) {
        self.id = UUID().uuidString
        self.userId = userId
        self.type = type
        self.coins = coins
        self.title = title
        self.timestamp = Date()
        self.relatedId = relatedId
    }
}

// MARK: - User Rewards Summary
@Model
final class UserRewardsSummary {
    @Attribute(.unique) var id: String
    var userId: String
    var totalCoinsEarned: Int
    var totalCoinsSpent: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var supplementsTaken: Int
    var quizzesCompleted: Int
    
    // Achievement flags
    var hasFirstStepAchievement: Bool
    var hasWeekWarriorAchievement: Bool
    var hasQuizMasterAchievement: Bool
    var hasSupplementProAchievement: Bool
    var has30DayStreakAchievement: Bool
    var hasHealthGuruAchievement: Bool
    
    init(userId: String) {
        self.id = userId
        self.userId = userId
        self.totalCoinsEarned = 0
        self.totalCoinsSpent = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.supplementsTaken = 0
        self.quizzesCompleted = 0
        self.hasFirstStepAchievement = false
        self.hasWeekWarriorAchievement = false
        self.hasQuizMasterAchievement = false
        self.hasSupplementProAchievement = false
        self.has30DayStreakAchievement = false
        self.hasHealthGuruAchievement = false
    }
    
    var availableCoins: Int {
        totalCoinsEarned - totalCoinsSpent
    }
    
    func checkAndUpdateAchievements() {
        // First Step: Take first supplement
        if supplementsTaken >= 1 && !hasFirstStepAchievement {
            hasFirstStepAchievement = true
        }
        
        // Week Warrior: 7-day streak
        if currentStreak >= 7 && !hasWeekWarriorAchievement {
            hasWeekWarriorAchievement = true
        }
        
        // Quiz Master: Complete 10 quizzes
        if quizzesCompleted >= 10 && !hasQuizMasterAchievement {
            hasQuizMasterAchievement = true
        }
        
        // Supplement Pro: Take 50 supplements
        if supplementsTaken >= 50 && !hasSupplementProAchievement {
            hasSupplementProAchievement = true
        }
        
        // 30 Day Streak
        if currentStreak >= 30 && !has30DayStreakAchievement {
            has30DayStreakAchievement = true
        }
        
        // Health Guru: 100 supplements + 20 quizzes
        if supplementsTaken >= 100 && quizzesCompleted >= 20 && !hasHealthGuruAchievement {
            hasHealthGuruAchievement = true
        }
    }
}

// MARK: - Favorite Supplement (persistent)
@Model
final class FavoriteSupplement {
    @Attribute(.unique) var id: String
    var supplementId: String
    var userId: String?
    var addedAt: Date
    var timing: String // "morning", "midday", "evening"
    
    init(supplementId: String, userId: String? = nil, timing: String = "morning") {
        self.id = "\(userId ?? "local")_\(supplementId)"
        self.supplementId = supplementId
        self.userId = userId
        self.addedAt = Date()
        self.timing = timing
    }
}
