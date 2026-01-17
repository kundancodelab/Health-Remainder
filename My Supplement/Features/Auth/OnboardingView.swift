//
//  OnboardingView.swift
//  My Supplement
//
//  App onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Your Supplements",
            description: "Never miss a dose. Track your daily vitamins and minerals with our easy-to-use calendar.",
            icon: "pills.fill",
            color: "FF6B6B"
        ),
        OnboardingPage(
            title: "Learn & Grow",
            description: "Discover the benefits of each supplement, optimal timing, and what works well together.",
            icon: "book.fill",
            color: "4ECDC4"
        ),
        OnboardingPage(
            title: "Stay Motivated",
            description: "Earn coins, unlock achievements, and build healthy streaks with our gamification system.",
            icon: "star.fill",
            color: "FFD93D"
        ),
        OnboardingPage(
            title: "Test Your Knowledge",
            description: "Take quizzes to reinforce what you've learned and earn bonus rewards.",
            icon: "brain.head.profile",
            color: "9B59B6"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
                    completeOnboarding()
                }
                .foregroundColor(.secondary)
                .padding()
            }
            
            // Pages
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.appPrimary : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding()
            
            // Action Button
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.appBackground)
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        appState.hasCompletedOnboarding = true
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: page.color).opacity(0.2))
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(Color(hex: page.color).opacity(0.3))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: page.color))
            }
            
            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
