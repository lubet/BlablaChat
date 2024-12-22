//
//  ContactModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/12/2024.
//

import Foundation

struct ContactModel: Identifiable {
    let id: String = UUID().uuidString
    let nom: String
    let prenom: String
    let email: String
}

//init(
//    id: String,
//    nom: String,
//    prenom: String,
//    email: String,
//    contactId: String
//) {
//    self.id = id
//    self.nom = nom
//    self.dateCreated = dateCreated
//    self.avatarLink = avatarLink
//    self.userId = userId
//}
//
//enum CodingKeys: String, CodingKey {
//    case id = "id"
//    case nom = "nom"
//    case prenom = "prenom"
//    case email = "email"
//    case contactId = "contact_id"
//}
