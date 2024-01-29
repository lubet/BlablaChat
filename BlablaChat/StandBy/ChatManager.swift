//
//  ChatManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 19/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Chats ( Conversations) -----------
struct Chat: Identifiable, Codable {
    var chat_id: String // = document_id unique auto
    var title: String
    var last_message: String // texte du dernier message
    var date_created: Date
    
    var id: String {
        chat_id
    }
}

// Chat_messages ----------------------------
struct Chat_message: Identifiable, Codable {
    var message_id: String // unique
    var chat_id: String    // -> Chat et -> Chat_members
    var texte: String
    var date_created: Date
    var user_id: String // Créateur du premier message (sender) -> users
    
    var id: String {
        message_id
    }
}

// Chat_members ----------------------------
struct Chat_member: Identifiable, Codable {
    var id: String      // unique
    var chat_id: String // = chats/chat_id unique
    var user_id: String // -> users
}

// ---------------------------------------------------------------------------------------------
final class ChatManager {
    
    static let shared = ChatManager()
    private init() { }
    
    private let chatsCollection = Firestore.firestore().collection("chats")
    
    private func chatDocument(chat_id: String) -> DocumentReference {
        chatsCollection.document(chat_id)
    }
    
    func addChat(title: String, last_message: String) -> String {
        // new chat
        let chatRef = chatsCollection.document()
        let chat_id = chatRef.documentID
        
        let data: [String:Any] = [
            "chat_id" : chat_id,
            "title": title,
            "last_message" : last_message,
            "date_created" : Timestamp()
        ]
        chatRef.setData(data, merge: false)
        return chat_id
    }

    func addMessage(chat_id: String, texte: String, from_user_id: String) {
        let messageRef = chatDocument(chat_id: chat_id).collection("messages").document()
        let message_id = messageRef.documentID
        
        let datamsg: [String:Any] = [
            "message_id" : message_id,
            "chat_id" : chat_id,
            "texte" : "Bonjour",
            "date_created" : Timestamp(),
            "from_user_id" : "Moi"
        ]
        messageRef.setData(datamsg, merge: false)
    }
}
