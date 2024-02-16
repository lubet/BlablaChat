//
//  NewContactManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/02/2024.
//
// Les contacts c'est "DBUser"

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct group_member: Identifiable, Codable {
    let id: String
    let contact_id: String
    let conversation_id: String
    let date_created: Timestamp
    
    init(
        id:String,
        contact_id:String,
        conversation_id:String,
        date_created:Timestamp
    ) {
        self.id = id
        self.contact_id = contact_id
        self.conversation_id = conversation_id
        self.date_created = Timestamp()
    }
}

struct conversation: Identifiable, Codable {
    let id:String
    let conversation_id:String
    let conversation_name:String
    let date_created:Timestamp
    
    init(
        id:String,
        conversation_id:String,
        conversation_name:String,
        date_created:Timestamp
    ) {
        self.id = id
        self.conversation_id = conversation_id
        self.conversation_name = conversation_name
        self.date_created = Timestamp()
    }
}

struct message: Identifiable, Codable {
    let id:String
    let from_id:String
    let message_text:String
    let date_send:Timestamp
    let conversation_id:String
    
    init(
        id:String,
        from_id:String,
        message_text:String,
        date_send:Timestamp,
        conversation_id:String
    ) {
        self.id = id
        self.from_id = from_id
        self.message_text = message_text
        self.date_send = Timestamp()
        self.conversation_id = conversation_id
    }
}
