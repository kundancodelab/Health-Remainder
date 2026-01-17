//
//  UserData.swift
//  My Supplement
//
//  Created by User on 17/01/26.
//

import Foundation

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


