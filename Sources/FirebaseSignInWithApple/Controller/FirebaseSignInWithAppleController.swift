//
//  FirebaseAuthController.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore

@Observable
final public class FirebaseSignInWithAppleController: NSObject {
    
    // MARK: Public
    
    public var state: FirebaseSignInWithAppleAuthState = .loading
    public var user: User?
    
    public func authenticate() {
        continueWithApple(.createToken)
    }
    
    public func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            NotificationCenter.post(error: error)
        }
    }
    
    public func deleteAccount() {
        continueWithApple(.revokeToken)
    }
    
    // MARK: - Internal
    
    var operationType: FirebaseSignInWithAppleOperationType?
    var currentNonce: String?
    
    func continueWithApple(_ operationType: FirebaseSignInWithAppleOperationType) {
        state = .authenticating
        self.operationType = operationType
        
        let nonce = FirebaseSignInWithAppleUtils.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.nonce = FirebaseSignInWithAppleUtils.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func deleteFirebaseAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseSignInWithAppleError.noCurrentUser
        }
        try await user.delete()
        state = .notAuthenticated
    }
    
    func startListeningToAuthChanges(path: String) {
        authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if self.state != .authenticating {
                self.state = user != nil ? .authenticated : .notAuthenticated
            }
            if let user {
                self.saveProfileIfNeeded(user, path: path)
            }
        }
    }
    
    private func saveProfileIfNeeded(_ user: User, path: String) {
        Task {
            do {
                let isNewUser = try await FirebaseSignInWithAppleUtils.isNewUserInFirestore(path: path, uid: user.uid)
                if !isNewUser {
                    self.state = .authenticated
                } else {
                    try await saveProfile(user, path: path)
                }
            } catch {
                self.state = .notAuthenticated
                NotificationCenter.post(error: error)
            }
        }
    }
    
    func stopListeningToAuthChanges() {
        guard authStateHandler != nil else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandler!)
    }
    
    func createToken(from authorization: ASAuthorization, currentNonce: String?) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw FirebaseSignInWithAppleError.noAppleIdCredential
        }
        self.appleIDCredential = appleIDCredential
        
        guard let operationType else {
            throw FirebaseSignInWithAppleError.noFirebaseSignInWithAppleOperationType
        }
        
        switch operationType {
        case .createToken:
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                throw FirebaseSignInWithAppleError.noIdentityToken
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw FirebaseSignInWithAppleError.noTokenString
            }
            try await signInToFirebase(idTokenString: idTokenString, nonce: nonce)
            
        case .revokeToken:
            guard let authorizationCode = appleIDCredential.authorizationCode,
               let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
                throw FirebaseSignInWithAppleError.noAuthorizationCodeString
            }
            try await revokeToken(authorizationCodeString: authorizationCodeString)
        }
    }
    
    // MARK: Private
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var appleIDCredential: ASAuthorizationAppleIDCredential?
    
    private func saveProfile(_ user: User, path: String) async throws {
        let reference = Firestore.firestore().collection(path).document(user.uid)
        try await reference.setData(["userUid" : user.uid])
    }
    
    private func signInToFirebase(idTokenString: String, nonce: String) async throws {
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)
        try await Auth.auth().signIn(with: credential)
    }
    
    private func revokeToken(authorizationCodeString: String) async throws {
        try await Auth.auth().revokeToken(withAuthorizationCode: authorizationCodeString)
        try await deleteFirebaseAccount()
    }
}
