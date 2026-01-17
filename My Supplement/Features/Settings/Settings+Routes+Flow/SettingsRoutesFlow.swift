//
//  SettingsRoutesFlow.swift
//  My Supplement
//
//  Settings feature navigation routes
//

import Foundation
import SwiftUI

enum SettingsFlow: NavigationDestination, Hashable {
    case profile
    case lifeStage
    case supplementHistory
    case quizHistory
    case privacyPolicy
    case termsOfService
    
    var title: String {
        switch self {
        case .profile:
            return "Profile"
        case .lifeStage:
            return "Life Stage"
        case .supplementHistory:
            return "Supplement History"
        case .quizHistory:
            return "Quiz History"
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfService:
            return "Terms of Service"
        }
    }
    
    var destinationView: some View {
        switch self {
        case .profile:
            ProfileRow()
        case .lifeStage:
            LifeStageSettingsView()
        case .supplementHistory:
            SupplementHistoryView()
        case .quizHistory:
            QuizHistoryView()
        case .privacyPolicy:
            Text("Privacy Policy")
        case .termsOfService:
            Text("Terms of Service")
        }
    }
}

typealias SettingsRouterFlow = Router<SettingsFlow>
