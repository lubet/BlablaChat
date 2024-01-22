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
struct chat: Identifiable, Codable {
    var chat_id: String // = document_id unique
    var title: String
    var last_message: String // texte du dernier message
    var date_created: Date
    var id: String {
        chat_id
    }
}
// chat_messages ----------------------------
struct chat_messages: Identifiable, Codable {
    var id: String // unique
    var texte: String
    var date_created: Date
    var user_id: String // Créateur du premier message (sender) -> users
}

// chat_members ----------------------------
struct chat_members: Identifiable, Codable {
    var id: String      // unique
    var chat_id: String // = chats/chat_id unique
    var user_id: String // -> users
}

// ---------------------------------------------------------------------------------------------
final class ChatManager {
    
    static let shared = ChatManager()
    init() { }
    
    private let chatsCollection: CollectionReference = Firestore.firestore().collection("chats")
    
}
