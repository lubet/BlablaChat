//
//  TokenModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 12/10/2024.
//
// Un token par user

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct TokenModel {
    let user_id: String
    let token: String
    let time_stamp: Timestamp
    let nom: String
}
