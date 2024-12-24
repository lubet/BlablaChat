//
//  Conversations.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 24/12/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Conversation: Identifiable {
    let conversation_id: String
    let date_creation: Timestamp
    let last_message_id: String
    var id: String {
        conversation_id
    }
    
    init(
        conversation_id: String,
        date_creation: Timestamp,
        last_message_id: String
    ) {
        self.conversation_id = conversation_id
        self.date_creation = Timestamp()
        self.last_message_id = last_message_id
    }

}
