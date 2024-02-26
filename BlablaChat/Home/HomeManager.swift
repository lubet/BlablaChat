//
//  HomeManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/02/2024.
//
// Liste du dernier message reçu ou envoyé par conversation
// --------------------------------------------------------

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

struct ChatItem: Identifiable, Codable {
    let conversation_id: String
    let conversation_name: String
    let from_id: String
    let to_id: String
    let message_text: String
    let date_send: Timestamp
    
    var id: String {
        conversation_id
    }
    
    init(
        conversation_id: String,
        conversation_name: String,
        from_id: String,
        to_id: String,
        message_text: String,
        date_send: Timestamp
    ) {
        self.conversation_id = conversation_id
        self.conversation_name = conversation_name
        self.from_id = from_id
        self.to_id = to_id
        self.message_text = message_text
        self.date_send = Timestamp()
    }
}

final class HomeManager {
    
    static let shared = HomeManager()
    
    init() { }
    
    // -------------------------------------------------
    private let DBUserCollection = db.collection("users")
    
    private func userDocument(email:String) -> DocumentReference {
        return DBUserCollection.document(email)
    }
    
    // -------------------------------------------------
    private let groupMemberCollection = db.collection("group_member")
    
    // -------------------------------------------------
    private let conversationCollection = db.collection("conversation")

    private func conversationDocument(conversation_id: String) -> DocumentReference {
        return conversationCollection.document(conversation_id)
    }
    // -------------------------------------------------

    private let messageCollection = db.collection("message")

    
    //===============================================
    
    
    // Sous-collections de conversation
    func getMyMessages(user_id: String) async throws -> [Message]{
        
        var myMessage = [Message]()
        
        let messageSnap  = try await messageCollection
            .whereFilter(Filter.orFilter([
            Filter.whereField("from_id", isEqualTo: user_id),
            Filter.whereField("to_id", isEqualTo: user_id)
            ]))
            .getDocuments()

        print("** \(messageSnap.documents)")
        
        for document in messageSnap.documents {
            let message = try document.data(as: Message.self)
            myMessage.append(message)
        }
        print("return myMessage \(myMessage)")
        return myMessage
    }
    
    // Renvoie le nom de la conversaion correspondant au message
    func getConversation(chatRoom_id: String) async throws -> [Conversation] {
        
        var chatRooms = [Conversation]()
        
        let chatRoomSnap = try await conversationCollection
            .whereField("conversation_id",isEqualTo: chatRoom_id)
            .getDocuments()
        
        for document in chatRoomSnap.documents {
            let chat = try document.data(as: Conversation.self)
            chatRooms.append(chat)
        }
        return chatRooms
        
    }
    
    // Dernier message de chaque discussion
//    func lastMessages(from_to: String) async throws {
//        let querySnapShot = try await conversationCollection.getDocuments()
//        for document in querySnapShot.documents {
//            let document_id = document.documentID
//            let messageSnapShot = try await messageCollection
//                .order(by: "date_send", descending: <#T##Bool#>)
//        }
//
//    }
        
//        var messages = [Message]()
//
//        // Messages envoyés par moi
//        let querySnapShot = try await messageCollection
//            .whereField("from_id", isEqualTo: from_to)
//            .order(by: "date_send", descending: true)
//            .getDocuments()
//        for document in querySnapShot.documents {
//            let mes = try document.data(as: Message.self)
//            messages.append(mes)
//            print("\(messages)")
//        }
        
        // Recher dans membre tous les conversations_id égaux aus miens -> les contact_id concernés
}

