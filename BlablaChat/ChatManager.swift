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
    
    let db = Firestore.firestore()
    
    // A la création de la discussion cad 1er message
    func addChat(date_created: Date, last_message: String, title: String) -> String{
        // new chat
        let document = db.collection("chats").document()
        let chat_id = document.documentID

        let data: [String:Any] = [
            "chat_id" : chat_id,
            "title": title,
            "last_message" : last_message,
            "date_created" : Date()
        ]
        
        // Création du chat
        document.setData(data, merge: false)
        
       return chat_id
        
    }
    
    
    // Ajout des messages par la suite cad après la création du premier
    func addMessage(chat_id: String, texte: String, date_created: Date, user_id: String) {
        // Création d'un objet message vide pour récupérer l'ID du message

        let data: [String:Any] = [
            "id" : chat_id,
            "texte" : texte,
            "date_created" : Timestamp(),
            "user_id" : Timestamp()
        ]
        // Création du message
        db.collection("chats/messages").document().setData(data, merge: false)
    }
    
}
