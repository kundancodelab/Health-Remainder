//
//  MainTabView.swift
//  My Supplement
//
//  Main tab navigation with 5 tabs
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab: Int, CaseIterable {
        case home
        case supplements
        case quiz
        case rewards
        case settings
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .supplements: return "Supplements"
            case .quiz: return "Quiz"
            case .rewards: return "Rewards"
            case .settings: return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .supplements: return "pills.fill"
            case .quiz: return "questionmark.circle.fill"
            case .rewards: return "star.fill"
            case .settings: return "gearshape.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .home: return .orange
            case .supplements: return .green
            case .quiz: return .purple
            case .rewards: return .yellow
            case .settings: return .gray
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(Tab.home.title, systemImage: Tab.home.icon)
            }
            .tag(Tab.home)
            
            NavigationStack {
                SupplementListView()
            }
            .tabItem {
                Label(Tab.supplements.title, systemImage: Tab.supplements.icon)
            }
            .tag(Tab.supplements)
            
            NavigationStack {
                QuizView()
            }
            .tabItem {
                Label(Tab.quiz.title, systemImage: Tab.quiz.icon)
            }
            .tag(Tab.quiz)
            
            NavigationStack {
                RewardsView()
            }
            .tabItem {
                Label(Tab.rewards.title, systemImage: Tab.rewards.icon)
            }
            .tag(Tab.rewards)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(Tab.settings.title, systemImage: Tab.settings.icon)
            }
            .tag(Tab.settings)
        }
        .tint(.orange)
    }
}

#Preview {
    MainTabView()
}
