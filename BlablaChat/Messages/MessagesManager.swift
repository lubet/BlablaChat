//
//  MessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let dbFS = Firestore.firestore()

final class MessagesManager {
    
    static let shared = MessagesManager()
    init() { }
    
    private let MessagesCollection = dbFS.collection("Messages")
    private func messageDocument(user_id:String) -> DocumentReference {
        return MessagesCollection.document(user_id)
    }
    
    // --------------------------------------------------------------
    
    private let SalonsUsersCollection = dbFS.collection("Salons-Users")
    
    // ---------------------------------------------------------------
    
    private let SalonsCollection = dbFS.collection("Salons")
    
    // Recherche du salon des interlocuteurs
    func searchSalon(contactId: String, userId: String) async -> String {
        do {
            let salonsUsersSnapshot = try await SalonsUsersCollection.whereFilter(Filter.orFilter([
                Filter.andFilter([
                    Filter.whereField("userId", isEqualTo: userId),
                ]),
                Filter.andFilter([
                    Filter.whereField("userId", isEqualTo: contactId),
                ])
            ])
            ).getDocuments()
            
            for duo in salonsUsersSnapshot.documents {
                let duo = try duo.data(as: Salons_Users.self)
                let salonId = duo.salonId
                return salonId
            }
        } catch {
            print("searchSalon - Error getting documents from members: \(error)")
        }
        print("searchSalon - La paire n'existe pas dans members")
        return ""
    }
    
    func newSalon() async throws -> String {
        let userRef = SalonsCollection.document()
        let docId = userRef.documentID
        
        let data: [String:Any] = [
            "salon_id" : docId
        ]
        try await userRef.setData(data, merge: false)

        
        return ""
    }
    
    // Get mes Messages
    func getMessages(userId: String) async throws -> [Messages] {
        let snapshot = try await Firestore.firestore().collection("Messages").getDocuments()
        
        var messages = [Messages]()
        
        for document in snapshot.documents {
            let msg = try document.data(as: Messages.self)
            if msg.from != userId {
                messages.append(msg)
            }
        }
        return messages
    }

}

