//
//  ChatManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 19/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// chats ( Conversations) -----------
struct chats: Identifiable, Codable {
    var chat_id: String // = document_id unique
    var title: String
    var last_message: String
    var date_created: Timestamp
    var id: String {
        chat_id
    }
}

// chat_members ----------------------------
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

// chat_messages ----------------------------
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

// ---------------------------------------------------------------------------------------------
final class ChatManager {
    
    private let chats: CollectionReference = Firestore.firestore().collection("chats")
    
    private let chat_members: CollectionReference = Firestore.firestore().collection("chat_members")
    
    private let chats_messages: CollectionReference = Firestore.firestore().collection("chat_messages")
    
    // Ajout d'une chat (-> création d'un messsage
    
    // Ajout d'un membre
    
    // Ajout d'un message
    
}
