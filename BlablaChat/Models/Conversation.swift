//
//  Conversations.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 24/12/2024.
//

import Foundation

struct Conversation: Identifiable {
    let conversation_id: String
    let date_creation: Date = Date()
    let last_messsage_id: String
    
    var id: String {
        conversation_id
    }
}
