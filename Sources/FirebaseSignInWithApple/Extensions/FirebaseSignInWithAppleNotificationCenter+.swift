//
//  FirebaseSignInWithAppleNotificationCenter+.swift
//  FirebaseSignInWithApple
//
//  Created by Alex Nagy on 05.02.2025.
//

import Foundation
import AuthenticationServices
import FirebaseCore

public extension NotificationCenter {
    static func post(error: Error) {
        if let error = error as? ASAuthorizationError {
            var message: String = ""
            switch error.code {
                case .canceled:
                message = "User canceled sign-in."
            case .unknown:
                message = "An unknown error occurred."
            case .invalidResponse:
                message = "The response from Apple was invalid."
            case .notHandled:
                message = "The authorization request was not handled."
            case .failed:
                message = "Apple failed to authorize."
            case .notInteractive:
                message = "The authorization request could not be completed interactively."
            case .matchedExcludedCredential:
                message = "The credential was previously rejected."
            case .credentialImport:
                message = "The credential could not be imported."
            case .credentialExport:
                message = "The credential could not be exported."
            @unknown default:
                if #available(iOS 17.0, *) {
                    switch error.code {
                    case .credentialImport:
                        message = "The credential could not be imported."
                    case .credentialExport:
                        message = "The credential could not be exported."
                    default:
                        message = "An unknown error occurred."
                    }
                } else {
                    message = "An unknown error occurred."
                }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.firebaseSignInWithAppleError, object: message)
            }
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.firebaseSignInWithAppleError, object: error.localizedDescription)
            }
        }
        
    }
}
