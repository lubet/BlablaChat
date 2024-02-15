//
//  HomeManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/02/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct Conversation: Identifiable {
    let id: String = UUID().uuidString
    let titre: String
    let last_date: Date
    let last_message:String
}

