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
struct Message: Identifiable, Codable {
    var message_id: String // unique
    var chat_id: String    // -> Chat et -> Chat_members
    var texte: String
    var date_created: Date
    var from_email: String // Créateur du premier message (sender) -> users
    
    var id: String {
        message_id
    }
}

// Chat_members ----------------------------
struct Member: Identifiable, Codable {
    let id: String      // unique
    let chat_id: String // = chats/chat_id unique
    let from_email: String
    let to_email: String
}

// Ajout d'un chat -------------------------------------------------------
final class ChatManager {
    
    static let shared = ChatManager()
    private init() { }
    
    // Chats
    private let chatsCollection = Firestore.firestore().collection("chats")
    
    private func chatDocument(chat_id: String) -> DocumentReference {
        chatsCollection.document(chat_id)
    }
    
    // Membres
    private let membersCollection = Firestore.firestore().collection("members")
    
    // Renvoie les membres du couple envoyeur/destinataire avec le chat_id (doivent en avoir un et un seul)
    func getMembers(from_email: String, to_email: String) async throws -> [Member] {
        let snapshot = try await membersCollection.getDocuments()
        var members: [Member] = []
        for document in snapshot.documents {
            let member = try document.data(as: Member.self)
            let fromemail = member.from_email
            let toemail = member.from_email
            if fromemail == from_email && toemail == to_email {
                members.append(member)
            }
        }
        return members
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

    // Ajout d'un message -----------------------------------------------
    func addMessage(chat_id: String, texte: String, from_email: String) {
        let messageRef = chatDocument(chat_id: chat_id).collection("messages").document()
        let message_id = messageRef.documentID
        
        let datamsg: [String:Any] = [
            "message_id" : message_id,
            "chat_id" : chat_id,
            "texte" : "Bonjour",
            "date_created" : Timestamp(),
            "from_email" : "Moi"
        ]
        messageRef.setData(datamsg, merge: false)
    }
}

