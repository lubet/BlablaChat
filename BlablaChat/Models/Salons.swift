//
//  Salons.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/12/2024.
//
// 

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Salons: Identifiable {
    let id: String
    let last_message_text: String
    let date_creation: Timestamp
    
    init(
        id: String,
        last_message_text: String,
        date_creation: String
    ) {
        self.id = id
        self.last_message_text = last_message_text
        self.date_creation = Timestamp()
    }

}
