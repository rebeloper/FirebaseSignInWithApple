//
//  FirebaseSignInWithAppleButtonAlertConfiguration.swift
//  FirebaseAuthSwiftUI
//
//  Created by Alex Nagy on 03.02.2025.
//

import Foundation

public struct FirebaseSignInWithAppleButtonAlertConfiguration {
    let title: String
    let message: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String
    
    public init(title: String, message: String, confirmButtonTitle: String, cancelButtonTitle: String) {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
    }
}
