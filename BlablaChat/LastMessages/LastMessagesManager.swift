//
//  LastMessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

final class LastMessagesManager {
    
    static let shared = LastMessagesManager()
    
    init() { }
    
    // Rooms
    private let salonCollection = db.collection("Salons")
    
    private func salonDocument(salon_id: String) -> DocumentReference {
        return salonCollection.document(salon_id)
    }

    // Users
    private let userCollection = db.collection("users")
    
    private func userDocument(user_id: String) -> DocumentReference {
        return userCollection.document(user_id)
    }
    
    // Membres
    private let memberCollection = db.collection("Membres")
    
    private func memberDocument(user_id: String) -> DocumentReference {
        return memberCollection.document(user_id)
    }
    
    // Renvoie tous les salons où userId est présent
    func fetchMyLastMessages(userId: String) async throws -> [Salons]? {
        do {
            let querySnapshot = try await salonCollection
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            var salons: [Salons] = []
            
            for document in querySnapshot.documents {
                let salon = try document.data(as: Salons.self)
                salons.append(salon)
            }
            return salons
        } catch {
            print("getAvatar - Error getting documents: \(error)")
        }
        print("getAvatar: non trouvé pour contact-id: \(userId)")
        
        return nil
    }
}
