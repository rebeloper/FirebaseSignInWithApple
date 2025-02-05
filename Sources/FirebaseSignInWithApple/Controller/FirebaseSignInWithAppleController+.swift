//
//  FirebaseSignInWithAppleController+.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import AuthenticationServices

extension FirebaseSignInWithAppleController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - ASAuthorizationControllerDelegate
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            do {
                try await createToken(from: authorization, currentNonce: currentNonce)
            } catch {
                state = .notAuthenticated
                NotificationCenter.post(error: error)
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        state = .notAuthenticated
        NotificationCenter.post(error: error)
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
