//
//  ErrorManager.swift
//  My Supplement
//
//  Created by User on 17/01/26.
//

import Foundation
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
