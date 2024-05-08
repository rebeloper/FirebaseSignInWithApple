//
//  FirebaseSignInWithAppleError.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation

public enum FirebaseSignInWithAppleError: Error {
    case noIdentityToken
    case noTokenString
    case noAppleIdCredential
    case noAuthDataResult
}
