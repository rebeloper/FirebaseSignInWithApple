//
//  FirebaseSignInWithApple+Date.swift
//  FirebaseSignInWithApple
//
//  Created by Alex Nagy on 05.02.2025.
//

import Foundation

extension Date {
    func isWithinPast(minutes: Int) -> Bool {
        let now = Date.now
        let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
        let range = now...timeAgo
        return range.contains(self)
    }
}
