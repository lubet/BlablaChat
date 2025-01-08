//
//  ContactModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import Foundation

struct ContactModel: Hashable {
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

