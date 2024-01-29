//
//  ContactManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/01/2024.
//
// Utilisé par NewMessageView

import Foundation

struct Contact4: Identifiable {
    let id: String
    let nom: String
    let prenom: String
    let email: String
}

final class Contact4Manager {
    
    static let shared =  Contact4Manager()
    
    init() { }
    
    func getAllContacts() async throws -> [Contact4] {
            [
                Contact4(id: "1", nom: "Dudu", prenom: "Maurice", email: "maurice@test.com"),
                Contact4(id: "2", nom: "Dudu", prenom: "Robert", email: "maurice@test.com"),
                Contact4(id: "3", nom: "Didi", prenom: "Emile", email: "maurice@test.com"),
                Contact4(id: "4", nom: "Toto", prenom: "Gaston", email: "maurice@test.com"),
                Contact4(id: "5", nom: "Tete", prenom: "Gaston", email: "maurice@test.com"),
            ]
        }
}
