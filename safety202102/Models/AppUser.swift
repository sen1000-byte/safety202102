//
//  AppUser.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import Foundation
import FirebaseFirestore

class AppUser {
    var userName: String
    var email: String
    let updatedAt: Timestamp
    
    var userID: String
    var friends: [String] = []
    
    init(data: [String: Any]) {
        userName = data["userName"] as? String ?? ""
        email = data["email"] as? String ?? ""
        updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
        userID = data["userID"] as? String ?? ""
        friends = data["friends"] as? [String] ?? [String]()
    }
}
