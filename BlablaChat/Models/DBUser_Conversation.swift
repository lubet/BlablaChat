//
//  DBUser_Conversation.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 24/12/2024.
//

import Foundation

struct DBUser_Conversation: Identifiable {
    let user_id: String
    let conversation_id: String
    var id: String {
        user_id
    }
}
