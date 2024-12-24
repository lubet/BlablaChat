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
    let message_id: String
    let conversation_id: String
    let date_message: Timestamp
    let texte: String
    let from_user_id: String
    let to_user_id: String
    var id: String {
        message_id
    }
    
    init(
        message_id: String,
        conversation_id: String,
        date_message: Timestamp,
        texte: String,
        from_user_id: String,
        to_user_id: String
    ) {
        self.message_id = message_id
        self.conversation_id = conversation_id
        self.date_message = Timestamp()
        self.texte = texte
        self.from_user_id = from_user_id
        self.to_user_id = to_user_id
    }

}
