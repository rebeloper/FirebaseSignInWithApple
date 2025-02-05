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
    
    public func authenticate() async throws {
        try await continueWithApple(.createToken)
    }
    
    public func signOut() throws {
        try Auth.auth().signOut()
    }
    
    public func deleteAccount() async throws {
        try await continueWithApple(.revokeToken)
    }
    
    // MARK: - Internal
    
    var operationType: FirebaseSignInWithAppleOperationType?
    var onError: ((Error?) -> ())?
    var currentNonce: String?
    
    func continueWithApple(_ operationType: FirebaseSignInWithAppleOperationType, onError: ((Error?) -> Void)? = nil) {
        state = .authenticating
        self.onError = onError
        self.operationType = operationType
        
        let nonce = FirebaseSignInWithAppleUtils.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = FirebaseSignInWithAppleUtils.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @discardableResult
    func continueWithApple(_ operationType: FirebaseSignInWithAppleOperationType) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            continueWithApple(operationType) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    func signOut(onError: ((Error?) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
        } catch {
            onError?(error)
        }
    }
    
    func deleteFirebaseAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseSignInWithAppleError.noCurrentUser
        }
        try await user.delete()
        state = .notAuthenticated
    }
    
    func deleteFirebaseAccount(onError: ((Error?) -> Void)? = nil) {
        Task {
            do {
                try await deleteFirebaseAccount()
            } catch {
                onError?(error)
            }
        }
    }
    
    func startListeningToAuthChanges(path: String) {
        authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if self.state != .authenticating {
                self.state = user != nil ? .authenticated : .notAuthenticated
            }
            if let user {
                FirebaseSignInWithAppleUtils.isNewUserInFirestore(path: path, uid: user.uid) { result in
                    switch result {
                    case .success(let isNew):
                        if !isNew {
                            self.state = .authenticated
                        } else {
                            self.createNewProfile(forUser: user, atPath: path)
                        }
                    case .failure(let error):
                        self.state = .notAuthenticated
                        self.onError?(error)
                    }
                }
            }
        }
    }
    
    func stopListeningToAuthChanges() {
        guard authStateHandler != nil else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandler!)
    }
    
    func createToken(from authorization: ASAuthorization, currentNonce: String?, onError: ((Error?) -> Void)?) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            self.appleIDCredential = appleIDCredential
            
            guard let operationType else {
                onError?(FirebaseSignInWithAppleError.noTokenString)
                return
            }
            
            switch operationType {
            case .createToken:
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    onError?(FirebaseSignInWithAppleError.noIdentityToken)
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    onError?(FirebaseSignInWithAppleError.noTokenString)
                    return
                }
                signInToFirebase(idTokenString: idTokenString, nonce: nonce, onError: onError)
                
            case .revokeToken:
                guard let authorizationCode = appleIDCredential.authorizationCode,
                   let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
                    onError?(FirebaseSignInWithAppleError.noAuthorizationCodeString)
                    return
                }
                revokeToken(authorizationCodeString: authorizationCodeString, onError: onError)
            }
        } else {
            onError?(FirebaseSignInWithAppleError.noAppleIdCredential)
        }
    }
    
    // MARK: Private
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var appleIDCredential: ASAuthorizationAppleIDCredential?
    
    private func createNewProfile(forUser user: User, atPath path: String) {
        self.saveProfile(user, path: path) { error in
            if let error {
                self.state = .notAuthenticated
                self.onError?(error)
                return
            }
            self.state = .authenticated
        }
    }
    
    private func saveProfile(_ user: User, path: String, onError: ((Error?) -> Void)?) {
        let reference = Firestore.firestore().collection(path).document(user.uid)
        reference.setData(["userUid" : user.uid], completion: onError)
    }
    
    private func signInToFirebase(idTokenString: String, nonce: String, onError: ((Error?) -> Void)?) {
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { _, error in
            if let error {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                onError?(error)
                return
            }
        }
    }
    
    private func revokeToken(authorizationCodeString: String, onError: ((Error?) -> Void)?) {
        Auth.auth().revokeToken(withAuthorizationCode: authorizationCodeString) { error in
            if let error {
                self.signOut { error in
                    onError?(error)
                }
                self.state = .notAuthenticated
                onError?(error)
                return
            }
            self.deleteFirebaseAccount(onError: onError)
        }
    }
}
