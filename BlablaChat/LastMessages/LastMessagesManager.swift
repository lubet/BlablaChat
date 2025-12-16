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
    
    // Membres
    private let memberCollection = db.collection("Membres")
    
    private func memberDocument(user_id: String) -> DocumentReference {
        return memberCollection.document(user_id)
    }
    
    // Salons/Messages
    private let messagesCollection = db.collection("Messages")
    
    // Tous les messages d'un salon
    private func messagesCollection(salonId: String) -> CollectionReference {
        return salonDocument(salon_id: salonId).collection("Messages")
    }
    
    
    // Renvoie tous les salons dont fait partie le user courant
    func userSalons(userId: String) async throws -> [String]? {
        do {
            let querySnapshot = try await memberCollection
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            var salonsId: [String] = []
            
            for document in querySnapshot.documents {
                let membre = try document.data(as: Membres.self)
                salonsId.append(membre.salonId)
            }
            return salonsId
        } catch {
            print("userSalons - Error getting documents: \(error)")
        }
        print("userSalons: non trouvé pour userId: \(userId)")
        return nil
    }
    
    
    // Renvoie tous les messages d'un salon
    func userMessages(salonId: String) async throws -> [Messages]? {
        do {
            let querySnapshot = try await messagesCollection(salonId: salonId)
                .whereField("salon_id", isEqualTo: salonId)
                .getDocuments()
            
            var messages: [Messages] = []
            
            for document in querySnapshot.documents {
                let message = try document.data(as: Messages.self)
                messages.append(message)
            }
            return messages
        } catch {
            print("userMessages - Error getting documents: \(error)")
        }
        print("userMessages: non trouvé pour userId: \(salonId)")
        
        return nil
   }
   
    // Renvoi un salon pris dans "Salons"
    func getSalon(salonId: String) async throws -> Salons? {
        do {
            let querySnapshot = try await salonCollection
                .whereField("salon_id", isEqualTo: salonId)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let salon = try document.data(as: Salons.self)
                return salon
            }
        } catch {
            print("searchEmail - Error getting documents: \(error)")
        }
        return nil
    }

    // TODO Les salons dont fait partie le current user
    func getSalons(currentId: String) async throws -> [Salons] {
        let salons: [Salons] = []
        // Faire une requete dans Users/subSalons avec le currentUserId
        return salons
    }
}
