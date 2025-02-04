//
//  FirebaseSignInWithAppleButton.swift
//  Carrrds
//
//  Created by Alex Nagy on 03.02.2025.
//

import SwiftUI

public struct FirebaseSignInWithAppleButton<Label: View>: View {
    
    @Environment(\.firebaseAuth) private var firebaseAuth
    
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
            firebaseAuth.continueWithApple(.createToken, onError: onError)
        } label: {
            label()
        }
    }
}
