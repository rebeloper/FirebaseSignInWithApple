//
//  FirebaseSignInWithAppleButton.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public struct FirebaseSignInWithAppleButton: View {
    
    private var label: FirebaseSignInWithAppleButtonLabel
    private var onCompletion: ((Result<FirebaseSignInWithAppleResult, Error>) -> Void)
    
    @Environment(\.firebaseSignInWithApple) private var firebaseSignInWithApple
    
    public init(label: FirebaseSignInWithAppleButtonLabel, onCompletion: @escaping (Result<FirebaseSignInWithAppleResult, Error>) -> Void) {
        self.label = label
        self.onCompletion = onCompletion
    }
    
    public var body: some View {
        Button {
            firebaseSignInWithApple.continueWithApple(completion: onCompletion)
        } label: {
            switch label {
            case .signIn:
                Label("Sign in with Apple", systemImage: "applelogo")
            case .signUp:
                Label("Sign up with Apple", systemImage: "applelogo")
            case .continueWithApple:
                Label("Continue with Apple", systemImage: "applelogo")
            case .custom(let text):
                Label(text, systemImage: "applelogo")
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .bold()
        .foregroundColor(.white)
        .background {
            Color.black
        }
        .cornerRadius(6)
    }
    
}


