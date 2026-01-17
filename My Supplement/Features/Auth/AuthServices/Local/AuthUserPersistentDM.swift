//
//  AuthUserPersistentDM.swift
//  My Supplement
//
//  Created by User on 17/01/26.
//

import Foundation
import SwiftData
@Model
final class AuthUserPersistentDM {
    var fullName:String
    var email:String
    var profilePictureURL:URL?
    init(fullName: String, email: String, profilePictureURL: URL? = nil) {
        self.fullName = fullName
        self.email = email
        self.profilePictureURL = profilePictureURL
    }
}
