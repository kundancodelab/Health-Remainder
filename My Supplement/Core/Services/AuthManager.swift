//
//  AuthManager.swift
//  My Supplement
//
//  Firebase authentication manager (Firebase-ready with demo fallback)
//

import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit

// Note: To enable Firebase, uncomment the Firebase imports and code
// import FirebaseAuth
// import FirebaseCore
// import GoogleSignIn

@MainActor
@Observable
final class AuthManager {
    static let shared = AuthManager()
    
    var isAuthenticated = false
    var currentUser: AuthUser?
    var isLoading = false
    var error: AuthError?
    
    // For Apple Sign-In
    private var currentNonce: String?
    
    private init() {
        checkAuthState()
    }
    
    // MARK: - Auth State
    func checkAuthState() {
        // Check if we have a stored user
        if let uid = UserDefaults.standard.string(forKey: "uid"),
           let email = UserDefaults.standard.string(forKey: "userEmail"),
           !uid.isEmpty {
            currentUser = AuthUser(
                id: uid,
                email: email,
                displayName: UserDefaults.standard.string(forKey: "userName"),
                isEmailVerified: UserDefaults.standard.bool(forKey: "isEmailVerified")
            )
            isAuthenticated = true
        }
        
        // Firebase implementation would be:
        // if let firebaseUser = Auth.auth().currentUser {
        //     currentUser = AuthUser(from: firebaseUser)
        //     isAuthenticated = true
        // }
    }
    
    // MARK: - Email/Password Sign In
    func signIn(email: String, password: String) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Firebase implementation:
        // do {
        //     let result = try await Auth.auth().signIn(withEmail: email, password: password)
        //     currentUser = AuthUser(from: result.user)
        //     isAuthenticated = true
        //     saveUserToDefaults()
        // } catch {
        //     throw AuthError.firebaseError(error.localizedDescription)
        // }
        
        // Demo mode - simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // For demo, accept any credentials
        let uid = UUID().uuidString
        currentUser = AuthUser(
            id: uid,
            email: email,
            displayName: email.components(separatedBy: "@").first ?? "User",
            isEmailVerified: false
        )
        isAuthenticated = true
        saveUserToDefaults()
    }
    
    // MARK: - Email/Password Sign Up
    func signUp(email: String, password: String, displayName: String) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Firebase implementation:
        // do {
        //     let result = try await Auth.auth().createUser(withEmail: email, password: password)
        //     let changeRequest = result.user.createProfileChangeRequest()
        //     changeRequest.displayName = displayName
        //     try await changeRequest.commitChanges()
        //     try await result.user.sendEmailVerification()
        //     currentUser = AuthUser(from: result.user)
        //     isAuthenticated = true
        //     saveUserToDefaults()
        // } catch {
        //     throw AuthError.firebaseError(error.localizedDescription)
        // }
        
        // Demo mode
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        let uid = UUID().uuidString
        currentUser = AuthUser(
            id: uid,
            email: email,
            displayName: displayName,
            isEmailVerified: false
        )
        isAuthenticated = true
        saveUserToDefaults()
    }
    
    // MARK: - Apple Sign In
    func handleAppleSignIn(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredentials
        }
        
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Get user data from Apple
        let userIdentifier = appleIDCredential.user
        let email = appleIDCredential.email ?? "\(userIdentifier)@privaterelay.appleid.com"
        let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        
        // Firebase implementation would use identityToken and nonce:
        // guard let appleIDToken = appleIDCredential.identityToken,
        //       let idTokenString = String(data: appleIDToken, encoding: .utf8),
        //       let nonce = currentNonce else {
        //     throw AuthError.invalidCredentials
        // }
        //
        // let credential = OAuthProvider.appleCredential(
        //     withIDToken: idTokenString,
        //     rawNonce: nonce,
        //     fullName: appleIDCredential.fullName
        // )
        //
        // let result = try await Auth.auth().signIn(with: credential)
        // currentUser = AuthUser(from: result.user)
        
        // Demo mode
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        currentUser = AuthUser(
            id: userIdentifier,
            email: email,
            displayName: fullName.isEmpty ? "Apple User" : fullName,
            isEmailVerified: true
        )
        isAuthenticated = true
        saveUserToDefaults()
    }
    
    func prepareAppleSignIn() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async throws {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Firebase + Google Sign-In implementation:
        // guard let clientID = FirebaseApp.app()?.options.clientID else {
        //     throw AuthError.configurationError
        // }
        //
        // let config = GIDConfiguration(clientID: clientID)
        // GIDSignIn.sharedInstance.configuration = config
        //
        // guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        //       let window = windowScene.windows.first,
        //       let rootViewController = window.rootViewController else {
        //     throw AuthError.configurationError
        // }
        //
        // let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        // guard let idToken = result.user.idToken?.tokenString else {
        //     throw AuthError.invalidCredentials
        // }
        //
        // let credential = GoogleAuthProvider.credential(
        //     withIDToken: idToken,
        //     accessToken: result.user.accessToken.tokenString
        // )
        //
        // let authResult = try await Auth.auth().signIn(with: credential)
        // currentUser = AuthUser(from: authResult.user)
        
        // Demo mode
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        currentUser = AuthUser(
            id: UUID().uuidString,
            email: "google_user@gmail.com",
            displayName: "Google User",
            isEmailVerified: true
        )
        isAuthenticated = true
        saveUserToDefaults()
    }
    
    // MARK: - Password Reset
    func sendPasswordReset(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.invalidEmail
        }
        
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Firebase implementation:
        // try await Auth.auth().sendPasswordReset(withEmail: email)
        
        // Demo mode
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Just simulate success
    }
    
    // MARK: - Email Verification
    func sendEmailVerification() async throws {
        // Firebase implementation:
        // guard let user = Auth.auth().currentUser else {
        //     throw AuthError.notAuthenticated
        // }
        // try await user.sendEmailVerification()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        // Firebase implementation:
        // try Auth.auth().signOut()
        
        currentUser = nil
        isAuthenticated = false
        clearUserFromDefaults()
    }
    
    // MARK: - Delete Account
    func deleteAccount() async throws {
        isLoading = true
        
        defer { isLoading = false }
        
        // Firebase implementation:
        // guard let user = Auth.auth().currentUser else {
        //     throw AuthError.notAuthenticated
        // }
        // try await user.delete()
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        currentUser = nil
        isAuthenticated = false
        clearUserFromDefaults()
    }
    
    // MARK: - Helpers
    private func saveUserToDefaults() {
        guard let user = currentUser else { return }
        UserDefaults.standard.set(user.id, forKey: "uid")
        UserDefaults.standard.set(user.email, forKey: "userEmail")
        UserDefaults.standard.set(user.displayName, forKey: "userName")
        UserDefaults.standard.set(user.isEmailVerified, forKey: "isEmailVerified")
    }
    
    private func clearUserFromDefaults() {
        UserDefaults.standard.removeObject(forKey: "uid")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "isEmailVerified")
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Auth User Model
struct AuthUser: Identifiable {
    let id: String
    let email: String
    let displayName: String?
    let isEmailVerified: Bool
    var photoURL: URL?
    
    // Firebase helper initializer (uncomment when using Firebase):
    // init(from firebaseUser: FirebaseAuth.User) {
    //     self.id = firebaseUser.uid
    //     self.email = firebaseUser.email ?? ""
    //     self.displayName = firebaseUser.displayName
    //     self.isEmailVerified = firebaseUser.isEmailVerified
    //     self.photoURL = firebaseUser.photoURL
    // }
}

// MARK: - Auth Error
enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case notAuthenticated
    case configurationError
    case firebaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .configurationError:
            return "Authentication is not properly configured"
        case .firebaseError(let message):
            return message
        }
    }
}
