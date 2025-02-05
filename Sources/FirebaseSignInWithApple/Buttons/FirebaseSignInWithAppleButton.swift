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
    
    /// Signs in the user to Firebase Auth with Sign in with Apple
    /// - Parameters:
    ///   - label: the button label
    public init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label
    }
    
    public var body: some View {
        Button {
            firebaseSignInWithApple.authenticate()
        } label: {
            label()
        }
    }
}
