//
//  AuthRepositoryPrImp.swift
//  My Supplement
//
//  Created by User on 17/01/26.
//

import Foundation
final class AuthRepositoryPrImp:AuthReposityPr {
    
    func googleLogin(completion: @escaping (Result<Bool, any Error>) -> Void) {
        completion(.success(true))
    }
    
    func appleLogin(completion: @escaping (Result<Bool, any Error>) -> Void) {
        completion(.success(true))
    }
}
