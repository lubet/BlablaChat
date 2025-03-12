//
//  MessageFCM.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 12/03/2025.
//

import Foundation

struct MessageFCM {
    let userId: String
    let nom: String
    let fcmToken: String
    
    var id: String {
        userId
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nom = "nom"
        case FCMToken = "fcm_tpken"
    }
    
    init(
        userId: String,
        nom: String,
        fcmToken: String
    ) {
        self.userId = ""
        self.fcmToken = ""
        self.nom = ""
    }
}
