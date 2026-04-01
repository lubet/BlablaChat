//
//  FcmTokens.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/04/2026.
//

import Foundation

struct FcmTokens: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let fcmToken: String

//    init(id: String = UUID().uuidString, userId: String = "", fcmToken: String = "") {
//        self.id = id
//        self.userId = userId
//        self.fcmToken = fcmToken
//    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case fcmToken = "fcm_token"
    }
}
