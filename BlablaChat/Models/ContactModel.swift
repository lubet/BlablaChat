//
//  ContactModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 07/12/2024.
//

import Foundation

struct ContactModel: Identifiable {
    let id: String = UUID().uuidString
    let nom: String
    let prenom: String
    let email: String
}
