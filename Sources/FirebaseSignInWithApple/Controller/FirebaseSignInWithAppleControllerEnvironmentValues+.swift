//
//  FirebaseSignInWithAppleControllerEnvironmentValues+.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public struct FirebaseSignInWithAppleKey: EnvironmentKey {
    @MainActor
    public static var defaultValue = FirebaseSignInWithAppleController()
}

public extension EnvironmentValues {
    @MainActor
    var firebaseSignInWithApple: FirebaseSignInWithAppleController {
        get { self[FirebaseSignInWithAppleKey.self] }
        set { self[FirebaseSignInWithAppleKey.self] = newValue }
    }
}
