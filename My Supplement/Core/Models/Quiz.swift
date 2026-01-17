//
//  Quiz.swift
//  My Supplement
//
//  Quiz data models for SwiftUI
//

import Foundation

// MARK: - Quiz Question
struct QuizQuestion: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    let question: String
    let options: [String]
    let correctAnswer: String
    let explanation: String?
    let category: String?
    let difficulty: QuizDifficulty
    
    enum CodingKeys: String, CodingKey {
        case id, question, options, correctAnswer, explanation, category, difficulty
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.question = try container.decode(String.self, forKey: .question)
        self.options = try container.decode([String].self, forKey: .options)
        self.correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
        self.explanation = try container.decodeIfPresent(String.self, forKey: .explanation)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.difficulty = try container.decodeIfPresent(QuizDifficulty.self, forKey: .difficulty) ?? .medium
    }
    
    init(
        id: String = UUID().uuidString,
        question: String,
        options: [String],
        correctAnswer: String,
        explanation: String? = nil,
        category: String? = nil,
        difficulty: QuizDifficulty = .medium
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.category = category
        self.difficulty = difficulty
    }
}

// MARK: - Quiz Difficulty
enum QuizDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var coinsReward: Int {
        switch self {
        case .easy: return 5
        case .medium: return 10
        case .hard: return 15
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "4CAF50"
        case .medium: return "FF9800"
        case .hard: return "F44336"
        }
    }
}

// MARK: - Quiz State
struct QuizState {
    var currentQuestionIndex: Int = 0
    var selectedAnswer: String? = nil
    var isAnswerRevealed: Bool = false
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var coinsEarned: Int = 0
    var isCompleted: Bool = false
    
    var progress: Double {
        guard currentQuestionIndex > 0 else { return 0 }
        return Double(currentQuestionIndex) / Double(currentQuestionIndex + 1)
    }
    
    mutating func reset() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        isAnswerRevealed = false
        correctCount = 0
        incorrectCount = 0
        coinsEarned = 0
        isCompleted = false
    }
}

// MARK: - Quiz Result
struct QuizResult {
    let correct: Int
    let incorrect: Int
    let coinsEarned: Int
    let date: Date
    
    var total: Int { correct + incorrect }
    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
    
    var performanceLevel: String {
        switch percentage {
        case 90...100: return "Excellent! 🎉"
        case 80..<90: return "Great Job! 👍"
        case 70..<80: return "Good Work! 👏"
        case 60..<70: return "Not Bad! 🙂"
        case 50..<60: return "Keep Trying! 💪"
        default: return "Need Practice! 📚"
        }
    }
}
