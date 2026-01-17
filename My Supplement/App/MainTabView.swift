//
//  MainTabView.swift
//  My Supplement
//
//  Main tab navigation with MVVM Router pattern
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    // MARK: - Feature Routers
    @StateObject private var homeRouter = HomeRouterFlow()
    @StateObject private var supplementsRouter = SupplementsRouterFlow()
    @StateObject private var quizRouter = QuizRouterFlow()
    @StateObject private var rewardsRouter = RewardsRouterFlow()
    @StateObject private var settingsRouter = SettingsRouterFlow()
    
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
            // Home Tab with Router
            HomeContainerView()
                .environmentObject(homeRouter)
                .tabItem { Label(Tab.home.title, systemImage: Tab.home.icon) }
                .tag(Tab.home)
            
            // Supplements Tab with Router
            SupplementsContainerView()
                .environmentObject(supplementsRouter)
                .tabItem { Label(Tab.supplements.title, systemImage: Tab.supplements.icon) }
                .tag(Tab.supplements)
            
            // Quiz Tab with Router
            QuizContainerView()
                .environmentObject(quizRouter)
                .tabItem { Label(Tab.quiz.title, systemImage: Tab.quiz.icon) }
                .tag(Tab.quiz)
            
            // Rewards Tab with Router
            RewardsContainerView()
                .environmentObject(rewardsRouter)
                .tabItem { Label(Tab.rewards.title, systemImage: Tab.rewards.icon) }
                .tag(Tab.rewards)
            
            // Settings Tab with Router
            SettingsContainerView()
                .environmentObject(settingsRouter)
                .tabItem { Label(Tab.settings.title, systemImage: Tab.settings.icon) }
                .tag(Tab.settings)
        }
        .tint(.orange)
    }
}

// MARK: - Container Views with Router Pattern

struct HomeContainerView: View {
    @EnvironmentObject var router: HomeRouterFlow
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            HomeView()
                .navigationDestination(for: HomeFlow.self) { destination in
                    destination.destinationView
                }
        }
    }
}

struct SupplementsContainerView: View {
    @EnvironmentObject var router: SupplementsRouterFlow
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            SupplementListView()
                .navigationDestination(for: SupplementsFlow.self) { destination in
                    destination.destinationView
                }
        }
    }
}

struct QuizContainerView: View {
    @EnvironmentObject var router: QuizRouterFlow
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            QuizView()
                .navigationDestination(for: QuizFlow.self) { destination in
                    destination.destinationView
                }
        }
    }
}

struct RewardsContainerView: View {
    @EnvironmentObject var router: RewardsRouterFlow
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            RewardsView()
                .navigationDestination(for: RewardsFlow.self) { destination in
                    destination.destinationView
                }
        }
    }
}

struct SettingsContainerView: View {
    @EnvironmentObject var router: SettingsRouterFlow
    
    var body: some View {
        NavigationStack(path: $router.navPaths) {
            SettingsView()
                .navigationDestination(for: SettingsFlow.self) { destination in
                    destination.destinationView
                }
        }
    }
}

#Preview {
    MainTabView()
}


