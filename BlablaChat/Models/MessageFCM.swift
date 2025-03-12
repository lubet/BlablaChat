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
    let FCMToken: String
    
    var id: String {
        userId
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nom = "nom"
        case FCMToken = "fcm_token"
    }
    
    init(
        userId: String,
        nom: String,
        FCMtoken: String
    ) {
        self.userId = ""
        self.nom = ""
        self.FCMToken = ""
    }
}
