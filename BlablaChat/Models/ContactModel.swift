//
//  ContactModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import Foundation

struct ContactModel: Identifiable, Hashable {
    let id = UUID().uuidString
    let prenom: String
    let nom: String
    let email: String
    
    init(
        prenom: String,
        nom: String,
        email: String
    ) {
        self.prenom = prenom
        self.nom = nom
        self.email = email
    }

}

