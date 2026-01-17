//
//  LoginView.swift
//  My Supplement
//
//  User login screen
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSignUp = false
    @State private var rememberMe = false
    @State private var showForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @State private var showPasswordResetSent = false
    
    private var authManager: AuthManager { AuthManager.shared }
    
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
        .loadingOverlay(isLoading: authManager.isLoading, message: "Logging in...")
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Password Reset", isPresented: $showForgotPassword) {
            TextField("Email", text: $forgotPasswordEmail)
                .textContentType(.emailAddress)
            Button("Cancel", role: .cancel) { }
            Button("Send Reset Link") {
                Task {
                    await sendPasswordReset()
                }
            }
        } message: {
            Text("Enter your email to receive a password reset link")
        }
        .alert("Reset Email Sent", isPresented: $showPasswordResetSent) {
            Button("OK") { }
        } message: {
            Text("Check your inbox for password reset instructions")
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
                    forgotPasswordEmail = email
                    showForgotPassword = true
                }
                .font(.caption)
                .foregroundColor(.appPrimary)
            }
        }
    }
    
    // MARK: - Login Button
    private var loginButton: some View {
        Button {
            Task {
                await login()
            }
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
            SignInWithAppleButton()
                .frame(height: 50)
                .cornerRadius(12)
            
            SocialLoginButton(icon: "g.circle.fill", name: "Google") {
                Task {
                    await signInWithGoogle()
                }
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
    private func login() async {
        do {
            try await authManager.signIn(email: email, password: password)
            appState.refreshAuthState()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func signInWithGoogle() async {
        do {
            try await authManager.signInWithGoogle()
            appState.refreshAuthState()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func sendPasswordReset() async {
        do {
            try await authManager.sendPasswordReset(email: forgotPasswordEmail)
            showPasswordResetSent = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
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

// MARK: - Sign In With Apple Button
struct SignInWithAppleButton: UIViewRepresentable {
    @EnvironmentObject var appState: AppState
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleAppleSignIn), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(appState: appState)
    }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var appState: AppState
        
        init(appState: AppState) {
            self.appState = appState
        }
        
        @objc func handleAppleSignIn() {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let nonce = AuthManager.shared.prepareAppleSignIn()
            request.nonce = nonce
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                return UIWindow()
            }
            return window
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            Task {
                do {
                    try await AuthManager.shared.handleAppleSignIn(authorization: authorization)
                    await MainActor.run {
                        appState.refreshAuthState()
                    }
                } catch {
                    print("Apple Sign-In error: \(error)")
                }
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Apple Sign-In failed: \(error)")
        }
    }
}

// MARK: - Sign Up View
struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                    
                    if password != confirmPassword && !confirmPassword.isEmpty {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Button("Create Account") {
                        Task {
                            await createAccount()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isDisabled: !isFormValid))
                    .disabled(!isFormValid)
                    .padding(.top)
                }
                .padding(24)
            }
            .loadingOverlay(isLoading: isLoading, message: "Creating account...")
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
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
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    private func createAccount() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AuthManager.shared.signUp(email: email, password: password, displayName: name)
            appState.refreshAuthState()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
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
