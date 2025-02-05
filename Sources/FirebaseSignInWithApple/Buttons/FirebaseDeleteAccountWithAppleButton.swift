//
//  FirebaseDeleteAccountWithAppleButton.swift
//  Carrrds
//
//  Created by Alex Nagy on 03.02.2025.
//

import SwiftUI

public struct FirebaseDeleteAccountWithAppleButton<Label: View>: View {
    
    @Environment(\.firebaseSignInWithApple) private var firebaseSignInWithApple
    
    let alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration
    @ViewBuilder var label: () -> Label
    
    /// Deletes the user from Firebase Auth and Sign in with Apple
    /// - Parameters:
    ///   - alertConfiguration: the configuratiuon for the alert that is shown when the button is tapped
    ///   - label: the button label
    ///   - onError: completion handler that receives an error if one occoured
    public init(alertConfiguration: FirebaseSignInWithAppleButtonAlertConfiguration = FirebaseSignInWithAppleButtonAlertConfiguration(title: "Delete account", message: "This action cannot be undone. All your data will be deleted.\n\nThis is a security sensitive operation. You will be asked to sign in again before we can delete your account.\n\nAre you sure you want to delete your account?", confirmButtonTitle: "Confirm", cancelButtonTitle: "Cancel"),
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
                firebaseSignInWithApple.deleteAccount()
            }
            Button(alertConfiguration.cancelButtonTitle, role: .cancel) {
                
            }
        } message: {
            Text(alertConfiguration.message)
        }
    }
}
