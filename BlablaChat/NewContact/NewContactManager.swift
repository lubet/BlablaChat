//
//  NewContactManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/02/2024.
//

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
