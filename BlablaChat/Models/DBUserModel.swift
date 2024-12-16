//
//  DBUserModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/08/2024.
//

import Foundation

struct DBUser: Codable, Identifiable {
    let authId: String
    let email : String?
    let dateCreated: Date?
    let avatarLink: String?
    
    var id: String {
        authId
    }
    
    // Init du document à partir des données de l'authentification auxquelles on ajoute la date de création et le lien de l'image
    init(auth: AuthUser) {
        self.authId = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        self.avatarLink = nil
    }
    
    init(
        authId: String,
        email : String? = nil,
        dateCreated: Date? = nil,
        avatarLink: String? = nil
    ) {
        self.authId = authId
        self.email = email
        self.dateCreated = dateCreated
        self.avatarLink = avatarLink
    }
    
    enum CodingKeys: String, CodingKey {
        case authId = "auth_id"
        case email = "email"
        case dateCreated = "date_created"
        case avatarLink = "avatar_link"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.authId, forKey: .authId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.avatarLink, forKey: .avatarLink)
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.authId = try container.decode(String.self, forKey: .authId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.avatarLink = try container.decodeIfPresent(String.self, forKey: .avatarLink)
    }
}
