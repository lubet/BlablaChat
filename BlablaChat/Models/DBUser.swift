//
//  DBUserModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/08/2024.
//
// Création d'un user dans la base "users" à partir de l'authentification plus dateCreated, avatarLink et userId

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct DBUser: Codable, Identifiable {
    let id: String?
    let email : String?
    var dateCreated: Timestamp = Timestamp()
    let avatarLink: String?
    let userId: String
        
    // Init du document à partir des données de l'authentification auxquelles on ajoute la date de création, le lien de l'image
    // et un userId (servira dans les contacts)
    init(auth: AuthUser) {
        self.id = auth.uid
        self.email = auth.email
        self.dateCreated = Timestamp()
        self.avatarLink = nil
        self.userId = UUID().uuidString
    }
    
// Si on ne vaut créer un user dans "users" à partir de l'authentification:
    init(
        id: String? = nil,
        email : String? = nil,
        dateCreated: Timestamp = Timestamp(),
        avatarLink: String? = nil,
        userId: String = UUID().uuidString
    ) {
        self.id = id
        self.email = email
        self.dateCreated = dateCreated
        self.avatarLink = avatarLink
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email = "email"
        case dateCreated = "date_created"
        case avatarLink = "avatar_link"
        case userId = "user_id"
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
        self.dateCreated = try container.decodeIfPresent(Timestamp.self, forKey: .dateCreated)!
        self.avatarLink = try container.decodeIfPresent(String.self, forKey: .avatarLink)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)!
    }
}
