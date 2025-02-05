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
    public var previousState: FirebaseSignInWithAppleAuthState = .loading
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
        do {
            guard let user = Auth.auth().currentUser else {
                throw FirebaseSignInWithAppleError.noCurrentUser
            }
            guard let lastAuthenticationDate = user.metadata.lastSignInDate else {
                throw FirebaseSignInWithAppleError.noCurrentUserLastSignInDate
            }
            let needsReauthentication = !lastAuthenticationDate.isWithinPast(minutes: FirebaseSignInWithAppleConstants.reauthenticationIsRequiredAfterMinutes)
            
            if needsReauthentication {
                continueWithApple(.reauthenticateAndRevokeToken)
            } else {
                continueWithApple(.revokeToken)
            }
        } catch {
            NotificationCenter.post(error: error)
        }
    }
    
    // MARK: - Internal
    
    var operationType: FirebaseSignInWithAppleOperationType?
    var currentNonce: String?
    
    func continueWithApple(_ operationType: FirebaseSignInWithAppleOperationType) {
        previousState = state
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
            if let user {
                self.saveProfileIfNeeded(user, path: path)
            } else {
                self.state = .notAuthenticated
            }
        }
    }
    
    private func saveProfileIfNeeded(_ user: User, path: String) {
        Task {
            do {
                let isUserAlreadyInFirestore = try await FirebaseSignInWithAppleUtils.isUserAlreadyInFirestore(path: path, uid: user.uid)
                print(">>> is user already in firestore: \(isUserAlreadyInFirestore)")
                if isUserAlreadyInFirestore {
                    self.state = .authenticated
                    print(">>> state set to authenticated")
                } else {
                    try await saveProfile(user, path: path)
                    print(">>> profile saved: \(user.uid)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.state = .authenticated // TODO: - not working
                        print(">>> state set to authenticated")
                    }
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
            
        case .reauthenticateAndRevokeToken:
            guard let user = Auth.auth().currentUser else {
                throw FirebaseSignInWithAppleError.noCurrentUser
            }
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                throw FirebaseSignInWithAppleError.noIdentityToken
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                throw FirebaseSignInWithAppleError.noTokenString
            }
            try await reauthenticateAndRevokeToken(user, idTokenString: idTokenString, nonce: nonce, appleIDCredential: appleIDCredential)
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
    
    private func reauthenticateAndRevokeToken(_ user: User, idTokenString: String, nonce: String, appleIDCredential: ASAuthorizationAppleIDCredential) async throws {
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)
        try await user.reauthenticate(with: credential)
        
        guard let authorizationCode = appleIDCredential.authorizationCode,
           let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
            throw FirebaseSignInWithAppleError.noAuthorizationCodeString
        }
        try await revokeToken(authorizationCodeString: authorizationCodeString)
    }
    
    private func revokeToken(authorizationCodeString: String) async throws {
        try await Auth.auth().revokeToken(withAuthorizationCode: authorizationCodeString)
        try await deleteFirebaseAccount()
    }
}
