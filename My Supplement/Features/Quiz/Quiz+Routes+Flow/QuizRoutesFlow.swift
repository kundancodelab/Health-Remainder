//
//  QuizRoutesFlow.swift
//  My Supplement
//
//  Quiz feature navigation routes
//

import Foundation
import SwiftUI

enum QuizFlow: NavigationDestination, Hashable {
    case quizStart
    case quizHistory
    case quizResult(QuizResult)
    
    var title: String {
        switch self {
        case .quizStart:
            return "Start Quiz"
        case .quizHistory:
            return "Quiz History"
        case .quizResult:
            return "Quiz Result"
        }
    }
    
    var destinationView: some View {
        switch self {
        case .quizStart:
            QuizView()
        case .quizHistory:
            QuizHistoryView()
        case .quizResult(let result):
            QuizResultView(result: result) { }
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        switch self {
        case .quizStart:
            hasher.combine("quizStart")
        case .quizHistory:
            hasher.combine("quizHistory")
        case .quizResult(let result):
            hasher.combine("quizResult")
            hasher.combine(result.date)
        }
    }
    
    static func == (lhs: QuizFlow, rhs: QuizFlow) -> Bool {
        switch (lhs, rhs) {
        case (.quizStart, .quizStart):
            return true
        case (.quizHistory, .quizHistory):
            return true
        case (.quizResult(let l), .quizResult(let r)):
            return l.date == r.date
        default:
            return false
        }
    }
}

typealias QuizRouterFlow = Router<QuizFlow>
