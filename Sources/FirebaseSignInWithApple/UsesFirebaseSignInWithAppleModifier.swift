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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    controller.startListeningToAuthChanges()
                }
            }
            .onDisappear {
                controller.stopListeningToAuthChanges()
            }
    }
}

public extension View {
    func usesFirebaseSignInWithApple() -> some View {
        modifier(UsesFirebaseSignInWithAppleModifier())
    }
}
