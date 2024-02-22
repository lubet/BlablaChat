//
//  ChatsListManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/02/2024.
//
// Liste des chats Firestore
// Le modèle "Member" se trouve dans ChatManager

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

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
    
    // Renvoie les occurences du membre connecté
    func getMembre(auth_email: String) async throws -> [Member] {
        var Membre: [Member] = []

        do {
            let querySnapshot = try await membersCollection.whereFilter(Filter.orFilter([
                Filter.whereField("from_email", isEqualTo: auth_email),
                Filter.whereField("to_email", isEqualTo: auth_email)
            ])).getDocuments()
            
            for document in querySnapshot.documents {
                let membre = try document.data(as: Member.self)
                Membre.append(membre)
            }
        } catch {
            print("Erreur getChatsId: \(error)")
        }
        return Membre
    }
    
    // Récupere tous les chats dont les chat_id sont égales à ceux du membre connecté ci_dessus pour en retirer le titre
    // Pour chaque chat récupéré, récupérer tous les messages
    
}
