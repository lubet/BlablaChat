//
//  LastMessage.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 19/02/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LastMessage: Identifiable, Codable, Hashable {
    let id = UUID().uuidString
    let avatarLink: String
    let emailContact: String
    let texte: String
    let date: Timestamp
    let salonId: String
    let nom: String
    let prenom: String
    
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
