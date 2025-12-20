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
    func newSalon(last_message: String, receiver: String) async throws -> String {
        let salonRef = salonsCollection.document()
        let docId = salonRef.documentID
        
        let data: [String:Any] = [
            "salon_id" : docId,
            "date_created" : Timestamp(),
            "last_message": last_message,
            "receiver": receiver
        ]
        try await salonRef.setData(data, merge: false)
        return docId
    }

    // Enregistre le dernier message dans "salons
    func majLastMessageSalons(salonId: String, lastMessage: String, receiver: String) async throws {
        let data: [String:Any] = [
            Salons.CodingKeys.lastMessage.rawValue : lastMessage,
            Salons.CodingKeys.sender.rawValue : receiver
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
                return salon.sender
            }
        } catch {
            print("getToId - Error getting documents: \(error)")
        }
        return nil
    }
}
