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
    var dateCreated: Timestamp = Timestamp()
    var isChecked: Bool = false

    init(id: String = UUID().uuidString, nom: String, prenom: String, email: String = "", dateCreated: Timestamp = Timestamp(), isChecked: Bool = false) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.email = email
        self.dateCreated = dateCreated
        self.isChecked = isChecked
    }

}
