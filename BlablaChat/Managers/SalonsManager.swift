//
// //
//  MessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//
// Gestion des Salons et des ses sous-collections messages et users

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let dbFS = Firestore.firestore()

final class SalonsManager {
    
    static let shared = SalonsManager()
    init() { }
    
    // Salons ----------------------------------------------------
    private let salonsCollection = dbFS.collection("Salons")
        // Un salon
        private func salonDocument(salonId: String) -> DocumentReference {
            salonsCollection.document(salonId)
        }
    
    
    // ------------------------------------------------------------------------------------
    
    // Création d'un nouveau salon
    func newSalon(last_message: String) async throws -> String {
        let salonRef = salonsCollection.document()
        let docId = salonRef.documentID
        
        let data: [String:Any] = [
            "salon_id" : docId,
            "last_message": last_message,
            "date_created" : Timestamp(),
            "contact_id": "", // toID
            "user_id": "" // fromID
        ]
        try await salonRef.setData(data, merge: false)
        return docId
    }

    // Enregistre le dernier message dans "salons
    func majLastMessageSalons(salonId: String, lastMessage: String, userId: String, contactId: String) async throws {
        let data: [String:Any] = [
            Salons.CodingKeys.lastMessage.rawValue : lastMessage,
            Salons.CodingKeys.contactId.rawValue : contactId,
            Salons.CodingKeys.userId.rawValue : userId
        ]
        try await salonDocument(salonId: salonId).updateData(data)
    }

    // Retourne le contactId d'un salon
    func getSalonContactId(salonId: String) async throws -> String? {
        do {
            let querySalons = try await salonsCollection
                .whereField("salon_id", isEqualTo: salonId)
                .getDocuments()
            
            for unSalon in querySalons.documents {
                let salon = try unSalon.data(as: Salons.self)
                return salon.contactId
            }
        } catch {
            print("getToId - Error getting documents: \(error)")
        }
        return nil
    }
}
