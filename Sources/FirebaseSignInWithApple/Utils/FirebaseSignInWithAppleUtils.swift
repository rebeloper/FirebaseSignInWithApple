//
//  FirebaseSignInWithAppleUtils.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

struct FirebaseSignInWithAppleUtils {
    
    static func isNewUserInFirestore(path: String, uid: String) async throws -> Bool {
        do {
            let reference = Firestore.firestore().collection(path)
            try await reference.document(uid).getDocument()
            return true
        } catch {
            if let error = error as NSError?, let code = FirestoreErrorCode.Code(rawValue: error.code) {
                if code == .alreadyExists {
                    return false
                } else {
                    throw error
                }
            } else {
                throw error
            }
        }
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
