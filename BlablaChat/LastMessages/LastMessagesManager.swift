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
    
    // Salons
    private let salonCollection = db.collection("Salons")
    
    private func salonDocument(salon_id: String) -> DocumentReference {
        return salonCollection.document(salon_id)
    }
    
    // Messages sous Salons
    private let messagesCollection = db.collection("Messages")
    
    // Tous les messages d'un salon
    private func messagesCollection(salonId: String) -> CollectionReference {
        return salonDocument(salon_id: salonId).collection("Messages")
    }
    
    // subUsers sous Salons
    private let subUsersCollection = db.collection("subUsers")
    
    // Tous les subUsers d'un salon
    private func subUsersSalonCollection(salonId: String) -> CollectionReference {
        return salonDocument(salon_id: salonId).collection("subUsers")
    }
    
    //----------------------------------------------------------------------------
    
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

    //* Tous les salons dont fait partie un user 
    func userSalons(userId: String) async throws -> [String]? {
        var salonsId: [String] = []
        
        do {
            let querySnapshot = try await db.collectionGroup("subUsers")
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()
            
            let nb = querySnapshot.count
            print("nb: \(nb)")

            for document in querySnapshot.documents {
                let subUser = try document.data(as: SubUsers.self)
                salonsId.append(subUser.salonId)
            }
            return salonsId
        } catch {
            print("userSalons - Error getting documents: \(error)")
        }
        print("userSalons: non trouvé pour userId: \(userId)")
        return nil
    }
}
