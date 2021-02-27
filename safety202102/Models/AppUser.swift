//
//  AppUser.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import Foundation
import FirebaseFirestore

struct AppUser {
//    let userID: String
    let userName: String
    let email: String
//    let password: String
//    let active: Bool
//    let friends: [String] = []
    let updatedAt: Timestamp
    
    init(data: [String: Any]) {
//        userID = data["useID"] as! String
        userName = data["userName"] as! String
        email = data["email"] as! String
//        password = data["password"] as! String
//        active = data["active"] as! Bool
//        friends = data["friends"] as! [String]
        updatedAt = data["updatedAt"] as! Timestamp
    }
}
