//
//  User.swift
//  My Supplement
//
//  User data model for SwiftUI
//

import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    var id: String
    var userName: String
    var email: String
    var age: Int?
    var weight: Double?
    var gender: Gender?
    var lifeStage: LifeStage?
    var profilePicURL: String?
    var isEmailVerified: Bool
    var createdAt: Date?
    
    init(
        id: String = UUID().uuidString,
        userName: String,
        email: String,
        age: Int? = nil,
        weight: Double? = nil,
        gender: Gender? = nil,
        lifeStage: LifeStage? = nil,
        profilePicURL: String? = nil,
        isEmailVerified: Bool = false,
        createdAt: Date? = Date()
    ) {
        self.id = id
        self.userName = userName
        self.email = email
        self.age = age
        self.weight = weight
        self.gender = gender
        self.lifeStage = lifeStage
        self.profilePicURL = profilePicURL
        self.isEmailVerified = isEmailVerified
        self.createdAt = createdAt
    }
}

// MARK: - Gender
enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

// MARK: - Life Stage
enum LifeStage: String, Codable, CaseIterable {
    case child = "Child"
    case teenager = "Teenager"
    case adult = "Adult"
    case senior = "Senior"
    
    var description: String {
        switch self {
        case .child: return "Under 12 years"
        case .teenager: return "12-18 years"
        case .adult: return "18-65 years"
        case .senior: return "Over 65 years"
        }
    }
}

// MARK: - User Reward
struct UserReward: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var totalCoinsEarned: Int = 0
    var totalCoinsSpent: Int = 0
    
    var availableCoins: Int {
        totalCoinsEarned - totalCoinsSpent
    }
}

// MARK: - Quiz Attempt
struct QuizAttempt: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String
    var attemptDate: Date
    var correctCount: Int
    var incorrectCount: Int
    var coinsEarned: Int
    
    var totalQuestions: Int {
        correctCount + incorrectCount
    }
    
    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions) * 100
    }
}
