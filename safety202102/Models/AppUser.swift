//
//  AppUser.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import Foundation
import FirebaseFirestore

struct AppUser {
    let userName: String
    let email: String
    let updatedAt: Timestamp
    
    var userID: String
    var friends: [String] = []
    
    init(data: [String: Any]) {
        userName = data["userName"] as? String ?? ""
        email = data["email"] as? String ?? ""
        updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp()
        userID = data["userID"] as? String ?? ""
    }
}
