//
//  ChatsListManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/02/2024.
//
// Liste des chats Firestore

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct Chatlist: Codable, Identifiable {
    let chat_id: String
    let Titre: String
    let date_created: Timestamp
    let last_message: String
    
    var id: String {
        chat_id
    }
}

final class ChatsListManager {
    
    static let shared = ChatsListManager()
    init() { }
    
    // Chats
    private let chatsCollection = Firestore.firestore().collection("chats")
    
    // Messages - Sous-collections de chatsCollection
    private func chatDocument(chat_id: String) -> DocumentReference {
        chatsCollection.document(chat_id)
    }
    
    
    func getChatsList(my_id: String) {

        
        
    }
}
