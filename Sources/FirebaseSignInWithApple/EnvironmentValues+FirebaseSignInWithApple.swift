//
//  EnvironmentValues+FirebaseSignInWithApple.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public extension EnvironmentValues {
    var firebaseSignInWithApple: FirebaseSignInWithAppleController {
        get {
            return self[FirebaseSignInWithAppleControllerKey.self]
        }
        set {
            self[FirebaseSignInWithAppleControllerKey.self] = newValue
        }
    }
}
