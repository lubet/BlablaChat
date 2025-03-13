//
//  TokensFCM.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 13/03/2025.
//

import Foundation

struct FCMtoken {
    static var FCMtoken: String = ""
}

struct TokensFCM {
    let userId: String
    let nom: String
    let tokenFCM: String
    
    var id: String {
        userId
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nom = "nom"
        case tokenFCM = "token_fcm"
    }
    
    init(
        userId: String,
        nom: String,
        tokenFCM: String
    ) {
        self.userId = ""
        self.nom = ""
        self.tokenFCM = ""
    }
}
