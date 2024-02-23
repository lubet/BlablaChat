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
struct ChatSave: Identifiable, Codable {
    var chat_id: String // = from_email+to_email
    var title: String
    var last_message: String // texte du dernier message
    var date_created: Date
    
    var id: String {
        chat_id
    }
}

// Chat_messages -----------------------------
struct Message2: Identifiable, Codable {
    var message_id: String
    var chat_id: String    // = from_email+to_email
    var texte: String
    var date_created: Date
    var from_email: String // Créateur du premier message (sender) -> users
    var to_email: String
    
    var id: String {
        message_id
    }
}

// Chat_members ----------------------------
struct Member: Identifiable, Codable {
    let chat_id: String // = from_email+to_email
    let from_email: String
    let to_email: String
    
    var id: String {
        chat_id
    }
}

// -------------------------------------------------------
final class ChatManager {
    
    static let shared = ChatManager()
    private init() { }
    
    // Collection chats
    private let chatsCollection = Firestore.firestore().collection("chats")
    
    // Un document de la collection chats
    private func chatDocument(chat_id: String) -> DocumentReference {
        chatsCollection.document(chat_id)
    }
    
    // Collection membres
    private let membersCollection = Firestore.firestore().collection("members")
    
    
    // Recherche d'un duo membre avec son chat_id qui est égal à from_email + to_email
    func searchDuoMembers(from_email: String, to_email: String) async throws -> Bool {
        let keyId = from_email + to_email
        let snapshot = membersCollection.whereField("chat_id", isEqualTo: keyId)
        let nbDuo: Int = try await snapshot.getDocuments().count
        if nbDuo == 0 {
            return false
        } else if nbDuo > 1 {
            return false
        }
        return true
    }
    
    // Nouveau chat - chat_id = from_email + to_email
    func addChat(title: String, last_message: String, from_email: String, to_email: String) -> String {
        // new chat
        let chatRef = chatsCollection.document()
        let chat_id = from_email + to_email
        
        let data: [String:Any] = [
            "chat_id" : chat_id,
            "title": title,
            "last_message" : last_message,
            "date_created" : Timestamp()
        ]
        chatRef.setData(data, merge: false)
        return chat_id
    }

    // Ajout d'un message - chat_id = from_email + to_email - n messages peuvant avoir le même duo chat_id
    func addMessage(chat_id: String, texte: String, from_email: String, to_email:String) {
        let messageRef = chatDocument(chat_id: chat_id).collection("messages").document()
        let message_id = messageRef.documentID
        let datamsg: [String:Any] = [
            "message_id" : message_id,
            "chat_id" : chat_id,
            "texte" : texte,
            "date_created" : Timestamp(),
            "from_email" : from_email,
            "to_email": to_email
        ]
        messageRef.setData(datamsg, merge: false)
    }
    
    // Ajout d'un duo membre et de son chat_id unique
    func addDuoMember(from_email: String, to_email: String, chat_id: String) {
        let memberRef = membersCollection.document()
        
        let datamember: [String:Any] = [
            "chat_id" : chat_id,
            "from_email" : from_email,
            "to_email" : to_email
        ]
        memberRef.setData(datamember, merge: false)
    }
}

