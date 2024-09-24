//
//  DBUserModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/08/2024.
//

import Foundation

struct DBUser: Codable, Identifiable {
    let userId: String
    let email : String?
    let dateCreated: Date?
    let avatarLink: String?
    let FCMtoken: String?
    
    var id: String {
        userId
    }
    
    // Init du document à partir des données de l'authentification auxquelles on ajoute la date de création et le lien de l'image
    init(auth: AuthUser) {
        self.userId = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        self.avatarLink = nil
        self.FCMtoken = MyVariables.FCMtoken
    }
    
    init(
        userId: String,
        email : String? = nil,
        dateCreated: Date? = nil,
        avatarLink: String? = nil,
        FCMtoken: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.dateCreated = dateCreated
        self.avatarLink = avatarLink
        self.FCMtoken = FCMtoken
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case dateCreated = "date_created"
        case avatarLink = "avatar_link"
        case FCMtoken = "FCMtoken"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.avatarLink, forKey: .avatarLink)
        try container.encodeIfPresent(self.FCMtoken, forKey: .FCMtoken)
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.avatarLink = try container.decodeIfPresent(String.self, forKey: .avatarLink)
        self.FCMtoken = try container.decodeIfPresent(String.self, forKey: .FCMtoken)
    }
}
