//
//  NotificatioinName+.swift
//  FirebaseSignInWithApple
//
//  Created by Alex Nagy on 05.02.2025.
//

import Foundation

public extension Notification.Name {
    static let firebaseSignInWithAppleError = Notification.Name("firebaseSignInWithAppleError")
}

public extension NotificationCenter {
    static func post(error: Error) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.firebaseSignInWithAppleError, object: error.localizedDescription)
        }
    }
}
