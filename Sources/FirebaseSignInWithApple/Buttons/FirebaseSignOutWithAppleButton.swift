//
//  FirebaseSignOutWithAppleButton.swift
//  Carrrds
//
//  Created by Alex Nagy on 03.02.2025.
//

import SwiftUI

public struct FirebaseSignOutWithAppleButton<Label: View>: View {
    
    @Environment(\.firebaseSignInWithApple) private var firebaseSignInWithApple
    
    let alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration
    @ViewBuilder var label: () -> Label
    
    /// Signs out the user from Firebase Auth and Sign in with Apple
    /// - Parameters:
    ///   - alertConfiguration: the configuratiuon for the alert that is shown when the button is tapped
    ///   - label: the button label
    public init(alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration = FirebaseSignInWithAppleButtonAlertConfiguration(title: "Sign out", message: "Are you sure you want to sign out?", confirmButtonTitle: "Confirm", cancelButtonTitle: "Cancel"),
                @ViewBuilder label: @escaping () -> Label) {
        self.alertConfiguration = alertConfiguration
        self.label = label
    }
    
    @State private var isAlertPresented = false
    
    public var body: some View {
        Button {
            isAlertPresented.toggle()
        } label: {
            label()
        }
        .alert(alertConfiguration.title, isPresented: $isAlertPresented) {
            Button(alertConfiguration.confirmButtonTitle, role: .destructive) {
                firebaseSignInWithApple.signOut()
            }
            Button(alertConfiguration.cancelButtonTitle, role: .cancel) {
                
            }
        } message: {
            Text(alertConfiguration.message)
        }
    }
}
