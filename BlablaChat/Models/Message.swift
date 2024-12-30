//
//  MessageModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 24/12/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Message: Identifiable {
    let id: String
    let salon_id: String // -> salon
    let from: String // -> user_id de "Users"
    let texte: String
    let date_message: Timestamp
    
    init(
        id: String,
        salon_id: String,
        from: String,
        texte: String,
        date_message: Timestamp
    ) {
        self.id = id
        self.salon_id = salon_id
        self.date_message = Timestamp()
        self.texte = texte
        self.from = from
    }

}
