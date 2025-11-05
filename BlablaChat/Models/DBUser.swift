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
    let nom: String
    let prenom: String
    
    // Init du document à partir des données de l'authentification auxquelles on ajoute la date de création, le lien de l'image
    // et un userId (servira dans les contacts)
    init(auth: AuthUser, nom: String, prenom: String) {
        self.id = auth.uid
        self.email = auth.email
        self.dateCreated = Timestamp()
        self.avatarLink = nil
        self.userId = UUID().uuidString
        self.nom = nom
        self.prenom = prenom
    }
    
// Si on ne vaut créer un user dans "users" à partir de l'authentification:
    init(
        id: String? = nil,
        email : String? = nil,
        dateCreated: Timestamp = Timestamp(),
        avatarLink: String? = nil,
        userId: String = UUID().uuidString,
        nom: String = "",
        prenom: String = ""
    ) {
        self.id = id
        self.email = email
        self.dateCreated = dateCreated
        self.avatarLink = avatarLink
        self.userId = userId
        self.nom = nom
        self.prenom = prenom
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email = "email"
        case dateCreated = "date_created"
        case avatarLink = "avatar_link"
        case userId = "user_id"
        case nom = "nom"
        case prenom = "prenom"
    }
}
