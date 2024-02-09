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

struct Chats: Codable, Identifiable {
    let chat_id: String
    let from_email: String
    let to_email: String
    
    var id: String {
        chat_id
    }
}

let db = Firestore.firestore()

final class ChatsListManager {
    
    static let shared = ChatsListManager()
    
    init() { }
    
    // Chats
    private let chatsCollection = db.collection("chats")
    
    // Un document dans la collection chats
    private func chatDocument(chat_id: String) -> DocumentReference {
        chatsCollection.document(chat_id)
    }
    
    // Collection membres
    private let membersCollection = db.collection("members")
    
    // Renvoie les chats id de l'email connecté
    func getChatsId(auth_email: String) async throws -> [Chats] {
        var chatsId: [Chats] = []

        do {
            let querySnapshot = try await membersCollection.whereFilter(Filter.orFilter([
                Filter.whereField("from_email", isEqualTo: auth_email),
                Filter.whereField("to_email", isEqualTo: auth_email)
            ])).getDocuments()
            
            for document in querySnapshot.documents {
                print("\(document.documentID) => \(document.data())")
                let chatId = try document.data(as: Chats.self)
                chatsId.append(chatId)
            }
        } catch {
            print("Erreur getChatsId: \(error)")
        }
        return chatsId
    }
}
