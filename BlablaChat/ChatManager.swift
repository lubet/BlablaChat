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
    var chat_id: String // = from_email+to_email
    var title: String
    var last_message: String // texte du dernier message
    var date_created: Date
    
    var id: String {
        chat_id
    }
}

// Chat_messages ----------------------------
struct Message: Identifiable, Codable {
    var chat_id: String    // = from_email+to_email
    var texte: String
    var date_created: Date
    var from_email: String // Créateur du premier message (sender) -> users
    var to_email: String
    
    var id: String {
        chat_id
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

// Ajout d'un chat -------------------------------------------------------
final class ChatManager {
    
    static let shared = ChatManager()
    private init() { }
    
    // Chats
    private let chatsCollection = Firestore.firestore().collection("chats")
    
    // Messages
    private func chatDocument(chat_id: String) -> DocumentReference {
        chatsCollection.document(chat_id)
    }
    
    // Membres
    private let membersCollection = Firestore.firestore().collection("members")
    
    
    // Recherche d'un duo membre avec son chat_id qui est égal à from_email + to_email
    func searchDuoMembers(from_email: String, to_email: String) async throws -> Bool {
        let keyId = from_email + to_email
        let snapshot = membersCollection.whereField("chat_id", isEqualTo: keyId)
        let nbDuo: Int = try await snapshot.getDocuments().count
        if nbDuo == 0 {
            print("Pas de duo")
            return false
        } else if nbDuo > 1 {
            print("erreur: plus d'un duo")
            return false
        }
        print("Un duo existe")
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

    // Ajout d'un message - chat_id = from_email + to_email ------------------------------
    func addMessage(chat_id: String, texte: String, from_email: String, to_email:String) {
        let messageRef = chatDocument(chat_id: chat_id).collection("messages").document()
        // let message_id = messageRef.documentID
        let datamsg: [String:Any] = [
            "chat_id" : chat_id,
            "texte" : texte,
            "date_created" : Timestamp(),
            "from_email" : from_email,
            "to_email": to_email
        ]
        messageRef.setData(datamsg, merge: false)
    }
    
    // Ajout d'un duo membre et de son chat_id
    func addDuoMember(from_email: String, to_email: String, chat_id: String) {
        let memberRef = membersCollection.document()
        
        let datamember: [String:Any] = [
            "chat_id" : chat_id,
            "from_email" : from_email,
            "to_email" : to_email
        ]
        memberRef.setData(datamember, merge: false)
    }
    
// --------------------------------------------------------------------------------------
// Renvoi un duo from_email/to_email
//    func getDuoMembers(from_email: String, to_email: String) async throws -> [Member] {
//        let snapshot = try await membersCollection.getDocuments()
//        var members: [Member] = []
//        for document in snapshot.documents {
//            let member = try document.data(as: Member.self)
//            let fromemail = member.from_email
//            let toemail = member.to_email
//            if fromemail == from_email && toemail == to_email {
//                members.append(member)
//            }
//        }
//        return members
//    }

}

