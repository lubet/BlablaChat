//
//  DBUserModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/08/2024.
//
// Personne qui est logué

import Foundation

struct DBUser: Codable, Identifiable {
    let id: String
    let email : String?
    let dateCreated: Date?
    let avatarLink: String?
    let userId: String?
        
    // Init du document à partir des données de l'authentification auxquelles on ajoute la date de création et le lien de l'image
    init(auth: AuthUser) {
        self.id = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        self.avatarLink = nil
        self.userId = UUID().uuidString
    }
    
//    init(
//        id: String,
//        email : String? = nil,
//        dateCreated: Date? = nil,
//        avatarLink: String? = nil,
//        userId: String = UUID().uuidString
//    ) {
//        self.id = id
//        self.email = email
//        self.dateCreated = dateCreated
//        self.avatarLink = avatarLink
//        self.userId = userId
//    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email = "email"
        case dateCreated = "date_created"
        case avatarLink = "avatar_link"
        case userId = "userId"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.avatarLink, forKey: .avatarLink)
        try container.encodeIfPresent(self.userId, forKey: .userId)

    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.avatarLink = try container.decodeIfPresent(String.self, forKey: .avatarLink)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
    }
}
