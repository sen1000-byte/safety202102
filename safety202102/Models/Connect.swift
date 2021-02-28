//
//  Connect.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/28.
//

import Foundation
import FirebaseFirestore

struct Connect {
    let members: [String]
    let createdAt: Timestamp
    var latestTime: Timestamp
    
    init(data: [String: Any?]) {
        members = data["members"] as? [String] ?? []
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
        latestTime: data["latestTime"] as? Timestamp ?? Timestamp()
    }
}
