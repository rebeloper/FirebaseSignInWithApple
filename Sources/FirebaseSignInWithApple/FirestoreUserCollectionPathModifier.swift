//
//  FirestoreUserCollectionPathModifier.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import FirebaseAuth

struct FirestoreUserCollectionPathModifier: ViewModifier {
    
    @State private var controller = FirebaseAuthController()
    
    private let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.firebaseAuth, controller)
            .onAppear {
                controller.startListeningToAuthChanges(path: path)
            }
            .onDisappear {
                controller.stopListeningToAuthChanges()
            }
    }
}

public extension View {
    /// Sets up FirebaseSignInWithAppl and the collection path to the user documents in Firestore. Put this onto the root of your app
    /// - Parameter path: the collection path to the user documents in Firestore
    func configureFirebaseSignInWithAppleWith(firestoreUserCollectionPath path: String) -> some View {
        modifier(FirestoreUserCollectionPathModifier(path: path))
    }
}

