//
//  FirebaseSignInWithAppleButton.swift
//  Carrrds
//
//  Created by Alex Nagy on 03.02.2025.
//

import SwiftUI

public struct FirebaseSignInWithAppleButton<Label: View>: View {
    
    @Environment(\.firebaseSignInWithApple) private var firebaseSignInWithApple
    
    @ViewBuilder var label: () -> Label
    let onError: ((Error?) -> Void)?
    
    /// Signs in the user to Firebase Auth with Sign in with Apple
    /// - Parameters:
    ///   - label: the button label
    ///   - onError: completion handler that receives an optinal error if one occoured
    public init(@ViewBuilder label: @escaping () -> Label, onError: ((Error?) -> Void)? = nil) {
        self.label = label
        self.onError = onError
    }
    
    public var body: some View {
        Button {
            firebaseSignInWithApple.continueWithApple(.createToken, onError: onError)
        } label: {
            label()
        }
    }
    
    private func continueWithApple() {
        Task {
            do {
                try await firebaseSignInWithApple.authenticate()
            } catch {
                onError?(error)
            }
        }
    }
}
