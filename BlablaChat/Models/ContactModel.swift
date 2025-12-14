//
//  ContactModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import Foundation
import FirebaseFirestore

struct ContactModel: Identifiable, Hashable, Codable {
    let id: String
    let nom: String
    let prenom: String
    let email: String
    let dateCreated: Timestamp
    let isChecked: Bool
    let userId: String

    init(id: String = UUID().uuidString, nom: String = "", prenom: String = "", email: String = "", dateCreated: Timestamp = Timestamp(), isChecked: Bool = false, userId: String = "" ) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.email = email
        self.dateCreated = dateCreated
        self.isChecked = isChecked
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case nom
        case prenom
        case email
        case dateCreated = "date_created"
        case isChecked = "is_checked"
        case userId = "user_id"
    }
    
    func updateCompletion() -> ContactModel {
        return ContactModel(id: id, nom: nom, prenom: prenom, email: email, dateCreated: Timestamp(), isChecked: !isChecked)
    }
}

