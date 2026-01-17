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
    
    @StateObject private var supplementStore = SupplementStore()

    
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
                FavoriteSupplement.self,
                AuthUserPersistentDM.self
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
                .environment(supplementStore)
            
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
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    
    init() {
        // Check AuthManager state on main actor
        Task { @MainActor in
            self.isAuthenticated = AuthManager.shared.isAuthenticated
            self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
    }
    
    @MainActor
    func refreshAuthState() {
        isAuthenticated = AuthManager.shared.isAuthenticated
    }
}
