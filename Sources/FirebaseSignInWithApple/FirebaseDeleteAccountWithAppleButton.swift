//
//  FirebaseDeleteAccountWithAppleButton.swift
//  Carrrds
//
//  Created by Alex Nagy on 03.02.2025.
//

import SwiftUI

public struct FirebaseDeleteAccountWithAppleButton<Label: View>: View {
    
    @Environment(\.firebaseAuth) private var firebaseAuth
    
    let alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration
    @ViewBuilder var label: () -> Label
    let onError: ((Error) -> Void)?
    
    /// Deletes the user from Firebase Auth and Sign in with Apple
    /// - Parameters:
    ///   - alertConfiguration: the configuratiuon for the alert that is shown when the button is tapped
    ///   - label: the button label
    ///   - onError: completion handler that receives an error if one occoured
    public init(alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration = FirebaseSignInWithAppleButtonAlertConfiguration(title: "Delete account", message: "This action cannot be undone. All your data will be deleted.\n\nThis is a security sensitive operation. You will be asked to sign in again before we can delete your account.\n\nAre you sure you want to delete your account?", confirmButtonTitle: "Confirm", cancelButtonTitle: "Cancel"),
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
                revokeToken()
            }
            Button(alertConfiguration.cancelButtonTitle, role: .cancel) {
                
            }
        } message: {
            Text(alertConfiguration.message)
        }
    }
    
    private func revokeToken() {
        firebaseAuth.continueWithApple(.revokeToken) { error in
            if let error {
                signOut()
                onError?(error)
                return
            }
            deleteAccount()
        }
    }
    
    private func deleteAccount() {
        Task {
            do {
                try await firebaseAuth.deleteAccount()
            } catch {
                onError?(error)
            }
        }
    }
    
    private func signOut() {
        do {
            try firebaseAuth.signOut()
            self.firebaseAuth.state = .notAuthenticated
        } catch {
            onError?(error)
        }
    }
}
