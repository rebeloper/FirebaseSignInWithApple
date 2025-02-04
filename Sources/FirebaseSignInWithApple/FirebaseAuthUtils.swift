//
//  FirebaseAuthUtils.swift
//  
//
//  Created by Alex Nagy on 08.05.2024.
//

import Foundation
import FirebaseFirestore

public struct FirebaseAuthUtils {
    static func isNewUserInFirestore(path: String, uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let reference = Firestore.firestore().collection(path)
        reference.document(uid).getDocument { _, error in
            if let error = error as NSError?, let code = FirestoreErrorCode.Code(rawValue: error.code) {
                if code == .alreadyExists {
                    completion(.success(false))
                } else {
                    completion(.failure(error))
                }
            } else {
                completion(.success(true))
            }
        }
    }
}
