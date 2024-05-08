//
//  UsesFirebaseSignInWithAppleModifier.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI

struct UsesFirebaseSignInWithAppleModifier: ViewModifier {
    
    @StateObject private var controller = FirebaseSignInWithAppleController()
    
    func body(content: Content) -> some View {
        content
            .environment(\.firebaseSignInWithApple, controller)
    }
}

public extension View {
    func usesFirebaseSignInWithApple() -> some View {
        modifier(UsesFirebaseSignInWithAppleModifier())
    }
}
