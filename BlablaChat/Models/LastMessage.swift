//
//  LastMessage.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 19/02/2025.
//

import Foundation
import FirebaseFirestore


struct LastMessage: Identifiable, Codable, Hashable {
    let id: String
    let avatarLink: String
    let emailContact: String
    let texte: String
    let date: Timestamp
    let salonId: String
    let nom: String
    let prenom: String
    
    init(id: String = UUID().uuidString, avatarLink: String = "", emailContact: String = "", texte: String = "", date: Timestamp = Timestamp(), salonId: String = "", nom: String = "", prenom: String = "") {
        self.id = id
        self.avatarLink = avatarLink
        self.emailContact = emailContact
        self.texte = texte
        self.date = date
        self.salonId = salonId
        self.nom = nom
        self.prenom = prenom
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatarLink = "avatar_link"
        case emailContact = "email_contact"
        case texte = "message_texte"
        case date = "message_date"
        case salonId = "salon_id"
        case nom = "nom"
        case prenom = "prenom"
    }
}
