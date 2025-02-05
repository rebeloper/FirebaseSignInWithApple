//
//  NotificatioinName+.swift
//  FirebaseSignInWithApple
//
//  Created by Alex Nagy on 05.02.2025.
//

import Foundation

extension Notification.Name {
    static let firebaseSignInWithAppleError = Notification.Name("firebaseSignInWithAppleError")
}

extension NotificationCenter {
    static func post(error: Error) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.firebaseSignInWithAppleError, object: error.localizedDescription)
        }
    }
}
