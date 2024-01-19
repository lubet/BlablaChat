//
//  ChatManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 19/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Conversations -------------------------------------------------------------------------
private let chats_collection: CollectionReference = Firestore.firestore().collection("chats")

struct chats: Identifiable, Codable {
    var chat_id: String // = document_id unique
    var title: String
    var last_message: String
    var date_created: Timestamp
    var id: String {
        chat_id
    }
}

func newChat(chat_id: String, title: String, last_message: String, date_created: Timestamp) {
    // Create chat
    
    // Create members
    
    // Create message
}

// Chat membres ---------------------------------------------------------------------------------
private let chat_members_collection: CollectionReference = Firestore.firestore().collection("chat_members")

struct chat_members: Identifiable, Codable {
    var chat_id: String // = chats/chat_id unique
    var members: [member] = []
    var id: String {
        chat_id
    }
}
        struct member: Identifiable, Codable {
            var id: String
            var user_id: String
        }

// Chat messages ---------------------------------------------------------------------------------
private let chats_messages_collection: CollectionReference = Firestore.firestore().collection("chat_messages")

struct chat_messages: Identifiable, Codable {
    var chat_id: String // = chats/chat_id unique
    var messages: [message] = []
    var id: String {
        chat_id
    }
}
        struct message: Identifiable, Codable {
            var id: String
            var created_user_id: String
            var texte: String
            var date: Timestamp
        }



