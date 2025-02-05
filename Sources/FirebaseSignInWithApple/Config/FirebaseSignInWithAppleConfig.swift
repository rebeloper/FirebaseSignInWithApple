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
            
    }
}

public extension View {
    /// Sets up FirebaseSignInWithApple and the collection path to the user documents in Firestore. Put this onto the root of your app
    /// - Parameter path: the collection path to the user documents in Firestore
    func configureFirebaseSignInWithAppleWith(firestoreUserCollectionPath path: String) -> some View {
        modifier(FirestoreUserCollectionPathModifier(path: path))
    }
}

struct OnReceiveFirebaseSignInWithAppleErrorNotificationModifier: ViewModifier {
    
    let completion: (Error) -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.firebaseSignInWithAppleError)) { object in
                guard let error = object.object as? Error else { return }
                completion(error)
            }
    }
}

public extension View {
    func onFirebaseSignInWithAppleError(_ completion: @escaping (Error) -> Void) -> some View {
        modifier(OnReceiveFirebaseSignInWithAppleErrorNotificationModifier(completion: completion))
    }
}
