//
//  SignInWithAppleLabelType.swift
//
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation

public enum FirebaseSignInWithAppleLabelType: Equatable {
    case signIn, signUp, continueWithApple, signOut, deleteAccount, custom(text: String)
}
