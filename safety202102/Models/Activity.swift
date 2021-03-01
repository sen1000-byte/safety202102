//
//  Activity.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/01.
//

import Foundation
import Firebase
import FirebaseFirestore

class Activity {
    let userName: String
//    let userID: String
    
    var latestActiveTime: Timestamp!
    
    init(data: [String: Any?]) {
        userName = data["userName"] as? String ?? ""
        latestActiveTime = data["latestActiveTime"] as? Timestamp ?? Timestamp()
//        userID = data["email"] as? String ?? ""
    }
}
