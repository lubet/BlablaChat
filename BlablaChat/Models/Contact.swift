//
//  Contact.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 26/08/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Contact: Identifiable, Hashable {
    let id: String
    let nom: String
    let prenom: String
    let email: String
    let group: String
    var dateCreated: Timestamp = Timestamp()

    init(id: String = UUID().uuidString, nom: String, prenom: String, email: String = "", group: String = "", dateCreated: Timestamp = Timestamp()) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.email = email
        self.group = group
        self.dateCreated = dateCreated
    }

}
