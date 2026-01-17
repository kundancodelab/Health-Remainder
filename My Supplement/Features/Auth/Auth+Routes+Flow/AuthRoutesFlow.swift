//
//  AuthRoutesFlow.swift
//  My Supplement
//
//  Created by User on 17/01/26.
//

import Foundation
import SwiftUI

enum AuthFlow: NavigationDestination, Hashable {
    case login
    case signUp
    case resetPassword
    
    var title: String {
        switch self {
        case .login:
            return "Login"
        case .signUp:
            return "Sign Up"
        case .resetPassword:
            return "Reset Password"
        }
    }
    
    var destinationView: some View {
        switch self {
        case .login:
            LoginView()
        case .signUp:
            SignUpView()
        case .resetPassword:
            ResetPasswordView()
        }
    }
}

typealias AuthRouterFlow = Router<AuthFlow>

// MARK: - Reset Password View
struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.appPrimary)
            
            Text("Reset Password")
                .font(.title.weight(.bold))
            
            Text("Enter your email and we'll send you a link to reset your password.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(12)
            
            Button {
                Task {
                    await sendReset()
                }
            } label: {
                Text("Send Reset Link")
            }
            .buttonStyle(PrimaryButtonStyle(isDisabled: email.isEmpty))
            .disabled(email.isEmpty)
            
            Spacer()
        }
        .padding(24)
        .loadingOverlay(isLoading: isLoading, message: "Sending...")
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Password reset email sent. Check your inbox.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendReset() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AuthManager.shared.sendPasswordReset(email: email)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

