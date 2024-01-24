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
struct Chat: Identifiable, Codable {
    var chat_id: String // = document_id unique auto
    var title: String
    var last_message: String // texte du dernier message
    var date_created: Date
    
    var id: String {
        chat_id
    }
}

// chat_messages ----------------------------
struct Chat_message: Identifiable, Codable {
    var message_id: String // unique
    var texte: String
    var date_created: Date
    var user_id: String // Créateur du premier message (sender) -> users
    
    var id: String {
        message_id
    }
}

// chat_members ----------------------------
struct Chat_member: Identifiable, Codable {
    var id: String      // unique
    var chat_id: String // = chats/chat_id unique
    var user_id: String // -> users
}

// ---------------------------------------------------------------------------------------------
final class ChatManager {
    
    static let shared = ChatManager()
    init() { }
    
    let db = Firestore.firestore()
    
     // A la création de la discussion cad 1er message
    func addChat(title: String, last_message: String) -> String {
        // new chat
        let document = db.collection("chats").document()
        let chat_id = document.documentID

        let data: [String:Any] = [
            "chat_id" : chat_id,
            "title": title,
            "last_message" : last_message,
            "date_created" : Timestamp(),
        ]

        // Création du chat
        document.setData(data, merge: false)

       return chat_id
    }
    
    func addMessage(texte: String, from_user_id: String) {
        // new message avec id auto
        let document = db.collection("chats/messages").document()
        let message_id = document.documentID

        let data: [String:Any] = [
            "message_id" : message_id,
            "texte": texte,
            "from_user_id" : from_user_id,
            "date_created" : Timestamp(),
        ]

        // Création du message
        document.setData(data, merge: false)
  
    }
}
