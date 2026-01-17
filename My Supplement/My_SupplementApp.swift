//
//  My_SupplementApp.swift
//  My Supplement
//
//  SwiftUI Migration - Main App Entry with SwiftData
//

import SwiftUI
import SwiftData
import Combine

@main
struct My_SupplementApp: App {
    @StateObject private var appState = AppState()
    
    // SwiftData ModelContainer
    let modelContainer: ModelContainer
    
    init() {
        // Configure SwiftData with all models
        do {
            let schema = Schema([
                UserData.self,
                DailyRecord.self,
                QuizHistoryRecord.self,
                RewardTransaction.self,
                UserRewardsSummary.self,
                FavoriteSupplement.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.modelContainer = container
            
            // Setup DataManager with container
            Task { @MainActor in
                DataManager.shared.setup(with: container)
            }
            
            print("✅ SwiftData ModelContainer initialized successfully")
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .modelContainer(modelContainer)
                .onAppear {
                    // Clear badge on app launch
                    Task {
                        await NotificationManager.shared.clearBadge()
                    }
                }
        }
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    
    init() {
        // Check AuthManager state
        isAuthenticated = AuthManager.shared.isAuthenticated
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func refreshAuthState() {
        isAuthenticated = AuthManager.shared.isAuthenticated
    }
}
