//
//  AuthReposityPr.swift
//  My Supplement
//
//  Created by User on 17/01/26.
//

import Foundation

protocol AuthReposityPr  {
    func googleLogin(completion: @escaping (Result<Bool, Error>) -> Void)
    func appleLogin(completion: @escaping (Result<Bool, Error>) -> Void)
}
