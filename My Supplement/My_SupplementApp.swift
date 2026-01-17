//
//  My_SupplementApp.swift
//  My Supplement
//
//  SwiftUI Migration - Main App Entry
//

import SwiftUI

@main
struct My_SupplementApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    
    init() {
        // Check UserDefaults for auth state
        let uid = UserDefaults.standard.string(forKey: "uid")
        isAuthenticated = uid != nil && !uid!.isEmpty
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}
