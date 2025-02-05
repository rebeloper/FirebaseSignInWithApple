//
//  FirebaseSignInWithAppleConfig.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import SwiftUI
import FirebaseAuth

struct FirestoreUserCollectionPathModifier: ViewModifier {
    
    @State private var controller = FirebaseSignInWithAppleController()
    @State private var isErrorAlertPresented = false
    @State private var errorMessage: String = ""
    
    private let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.firebaseSignInWithApple, controller)
            .onAppear {
                controller.startListeningToAuthChanges(path: path)
            }
            .onDisappear {
                controller.stopListeningToAuthChanges()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.firebaseSignInWithAppleError)) { notification in
                guard let object = notification.object as? String else { return }
                errorMessage = object
                isErrorAlertPresented = true
            }
            .alert("Error", isPresented: $isErrorAlertPresented) {
                Button("OK") {
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage)
            }

    }
}

public extension View {
    /// Sets up FirebaseSignInWithApple and the collection path to the user documents in Firestore. Put this onto the root of your app
    /// - Parameter path: the collection path to the user documents in Firestore
    func configureFirebaseSignInWithAppleWith(firestoreUserCollectionPath path: String) -> some View {
        modifier(FirestoreUserCollectionPathModifier(path: path))
    }
}
