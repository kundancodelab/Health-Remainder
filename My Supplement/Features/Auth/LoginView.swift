//
//  LoginView.swift
//  My Supplement
//
//  User login screen
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSignUp = false
    @State private var rememberMe = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo
                logoSection
                
                // Form
                formSection
                
                // Login Button
                loginButton
                
                // Divider
                dividerSection
                
                // Social Login
                socialButtons
                
                // Sign Up Link
                signUpLink
            }
            .padding(24)
        }
        .background(Color.appBackground)
        .loadingOverlay(isLoading: isLoading, message: "Logging in...")
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
    }
    
    // MARK: - Logo
    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "pills.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("My Supplement")
                    .font(.title.weight(.bold))
                Text("Your health companion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    // MARK: - Form
    private var formSection: some View {
        VStack(spacing: 16) {
            // Email
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline.weight(.medium))
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.secondary)
                    TextField("Enter your email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(12)
            }
            
            // Password
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.weight(.medium))
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.secondary)
                    SecureField("Enter your password", text: $password)
                        .textContentType(.password)
                }
                .padding()
                .background(Color.appCardBackground)
                .cornerRadius(12)
            }
            
            // Remember Me & Forgot Password
            HStack {
                Button {
                    rememberMe.toggle()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: rememberMe ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(rememberMe ? .appPrimary : .secondary)
                        Text("Remember me")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .font(.caption)
                .foregroundColor(.appPrimary)
            }
        }
    }
    
    // MARK: - Login Button
    private var loginButton: some View {
        Button {
            login()
        } label: {
            Text("Sign In")
        }
        .buttonStyle(PrimaryButtonStyle(isDisabled: email.isEmpty || password.isEmpty))
        .disabled(email.isEmpty || password.isEmpty)
    }
    
    // MARK: - Divider
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
            Text("or continue with")
                .font(.caption)
                .foregroundColor(.secondary)
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    // MARK: - Social Buttons
    private var socialButtons: some View {
        HStack(spacing: 16) {
            SocialLoginButton(icon: "apple.logo", name: "Apple") {
                // Apple login
            }
            
            SocialLoginButton(icon: "g.circle.fill", name: "Google") {
                // Google login
            }
        }
    }
    
    // MARK: - Sign Up Link
    private var signUpLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.secondary)
            Button("Sign Up") {
                showSignUp = true
            }
            .foregroundColor(.appPrimary)
            .fontWeight(.medium)
        }
        .font(.subheadline)
    }
    
    // MARK: - Actions
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        isLoading = true
        
        // Simulate login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // For demo, accept any credentials
            UserDefaults.standard.set("demo_user_id", forKey: "uid")
            appState.isAuthenticated = true
        }
    }
}

// MARK: - Social Login Button
struct SocialLoginButton: View {
    let icon: String
    let name: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(name)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
}

// MARK: - Sign Up View
struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.title.weight(.bold))
                        .padding(.top)
                    
                    VStack(spacing: 16) {
                        FormField(label: "Full Name", icon: "person", text: $name)
                        FormField(label: "Email", icon: "envelope", text: $email, keyboardType: .emailAddress)
                        SecureFormField(label: "Password", icon: "lock", text: $password)
                        SecureFormField(label: "Confirm Password", icon: "lock", text: $confirmPassword)
                    }
                    
                    Button("Create Account") {
                        // Create account
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top)
                }
                .padding(24)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FormField: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                TextField(label, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
}

struct SecureFormField: View {
    let label: String
    let icon: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                SecureField(label, text: $text)
            }
            .padding()
            .background(Color.appCardBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
