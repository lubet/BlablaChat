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
    
    // Salons/Messages
    private let messagesCollection = db.collection("Messages")
    
    // Tous les messages d'un salon
    private func messagesCollection(salonId: String) -> CollectionReference {
        return salonDocument(salon_id: salonId).collection("Messages")
    }
    
    
    // Renvoie les enregs de "Membres" dont fait partie user - l'enreg de Membres contient le salonID.
    func userMembres(userId: String) async throws -> [Membres]? {
        do {
            let querySnapshot = try await memberCollection
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            var membres: [Membres] = []
            
            for document in querySnapshot.documents {
                let membre = try document.data(as: Membres.self)
                membres.append(membre)
            }
            return membres
        } catch {
            print("userMembres - Error getting documents: \(error)")
        }
        print("userMembres: non trouvé pour userId: \(userId)")
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
   
    // Renvoi un Salon
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
}
