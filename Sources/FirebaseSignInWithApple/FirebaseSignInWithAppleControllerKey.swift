//
//  FirebaseSignInWithAppleControllerKey.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

public struct FirebaseSignInWithAppleControllerKey: EnvironmentKey {
    @MainActor
    public static let defaultValue = FirebaseSignInWithAppleController()
}
