//
//  MembresManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let dbFS = Firestore.firestore()

final class MembresManager {
    
    static let shared = MembresManager()
    init() { }
    
    // Membres
    private let membresCollection = dbFS.collection("Membres")
   
    private func membreDocument(salonId: String, contactId: String, userId: String) -> DocumentReference {
        return membresCollection.document(salonId)
    }

    // Retourn le salon_id si il est commun à user et à contact sinon ""
    func searchMembres(contactId: String, userId: String) async throws -> String {
        do {
            let queryUser = try await membresCollection
                .whereField("user_id", isEqualTo: userId)
                .getDocuments()

            // ------------------------------------------
            
            let queryContact = try await membresCollection
                .whereField("user_id", isEqualTo: contactId)
                .getDocuments()
            
            // ------------------------------------------
            for unContact in queryContact.documents {
                let mContact = try unContact.data(as: Membres.self)
                let salonC = mContact.salonId
                for unUser in queryUser.documents {
                    let mUser = try unUser.data(as: Membres.self)
                    let salonU = mUser.salonId
                    if salonU == salonC {
                        // print("salonU salonC: \(salonU)")
                        return salonU
                    }
                }
            }
        } catch {
            print("getToId - Error getting documents: \(error)")
        }
        return("")
    }

    // Création de deux enregs dans membres un pour le contact, un pour le user, tous les deux avec le même n° de salon
    func newMembres(salonId: String, contactId: String, userId: String) async throws {
        
        // Création d'un enreg pour le contact
        let doc = membresCollection.document()
        let docId = doc.documentID
        
        let data: [String:Any] = [
            "id": docId,
            "salon_id": salonId,
            "user_id" : contactId
        ]
        try await doc.setData(data, merge: false)
        
        // Création d'un enreg pour le contact
        let doc2 = membresCollection.document()
        let docId2 = doc2.documentID
        
        let data2: [String:Any] = [
            "id": docId2,
            "salon_id": salonId,
            "user_id" : userId
        ]
        try await doc2.setData(data2, merge: false)
    }
    
    func searChMembre(userId: String) async throws -> Bool {
        
        
        return false
    }
}

