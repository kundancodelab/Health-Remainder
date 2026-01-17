//
//  RootView.swift
//  My Supplement
//
//  Root navigation handling auth state
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: appState.isAuthenticated)
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
