//
//  FirebaseSignOutWithAppleButton.swift
//  Carrrds
//
//  Created by Alex Nagy on 03.02.2025.
//

import SwiftUI

public struct FirebaseSignOutWithAppleButton<Label: View>: View {
    
    @Environment(\.firebaseAuth) private var firebaseAuth
    
    let alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration
    @ViewBuilder var label: () -> Label
    let onError: ((Error) -> Void)?
    
    /// Signs out the user from Firebase Auth and Sign in with Apple
    /// - Parameters:
    ///   - alertConfiguration: the configuratiuon for the alert that is shown when the button is tapped
    ///   - label: the button label
    ///   - onError: completion handler that receives an error if one occoured
    public init(alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration = FirebaseSignInWithAppleButtonAlertConfiguration(title: "Sign out", message: "Are you sure you want to sign out?", confirmButtonTitle: "Confirm", cancelButtonTitle: "Cancel"),
         @ViewBuilder label: @escaping () -> Label,
         onError: ((Error) -> Void)? = nil) {
        self.alertConfiguration = alertConfiguration
        self.label = label
        self.onError = onError
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
                signOut()
            }
            Button(alertConfiguration.cancelButtonTitle, role: .cancel) {
                
            }
        } message: {
            Text(alertConfiguration.message)
        }
    }
    
    private func signOut() {
        do {
            try firebaseAuth.signOut()
        } catch {
            onError?(error)
        }
    }
}
