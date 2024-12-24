//
//  ContactModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/12/2024.
//

import Foundation

struct ContactModel: Identifiable {
    let user_id: String
    let nom: String
    let prenom: String
    let email: String
    
    var id: String {
        user_id
    }
    
    init(
        user_id: String,
        nom: String,
        prenom: String,
        email: String
    ) {
        self.user_id = user_id
        self.nom = nom
        self.prenom = prenom
        self.email = email
    }
}
