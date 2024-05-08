//
//  FirebaseSignInWithAppleController.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import AuthenticationServices

final public class FirebaseSignInWithAppleController: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private var onContinueWithApple: ((Result<FirebaseSignInWithAppleResult, Error>) -> ())?
    fileprivate var currentNonce: String?
    
    @MainActor
    public func continueWithApple() async throws -> FirebaseSignInWithAppleResult {
        let result = try await withCheckedThrowingContinuation({ continuation in
            continueWithApple { result in
                continuation.resume(with: result)
            }
        })
        return result
    }
    
    @MainActor
    public func continueWithApple(completion: @escaping (Result<FirebaseSignInWithAppleResult, Error>) -> ()) {
        
        self.onContinueWithApple = completion
        
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
    
    // MARK: - ASAuthorizationControllerDelegate
    
    @MainActor
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        FirebaseSignInWithAppleUtils.createToken(from: authorization, currentNonce: currentNonce, completion: onContinueWithApple)
    }
    
    @MainActor
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onContinueWithApple?(.failure(error))
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
#if os(iOS)
    public var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window!
    }
#endif
    
#if os(macOS)
    public var window: NSWindow? {
        guard let window = NSApplication.shared.keyWindow else {
            return nil
        }
        return window
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window!
    }
#endif
}
