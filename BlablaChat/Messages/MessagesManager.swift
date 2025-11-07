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
    
    // Salons ----------------------------------------------------
    private let salonsCollection = dbFS.collection("Salons")
        // Un salon
        private func salonDocument(salonId: String) -> DocumentReference {
            salonsCollection.document(salonId)
        }
    
    // Messages ---------------------------------------------------
    private let messagesCollection = dbFS.collection("messages")
        // Un message
        private func messageDocument(id: String) -> DocumentReference {
            return messagesCollection.document(id)
        }
        // Tous les messages d'un salon
        private func messagesCollection(salonId: String) -> CollectionReference {
            return salonDocument(salonId: salonId).collection("messages")
        }
    
    // ---------------------------------------------------------------------------
    
    // Création d'un nouveau message
    func newMessage(salonId: String, fromId: String, texte: String, urlPhoto: String, toId: String) async throws {
        let document = messagesCollection(salonId: salonId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "salon_id" : salonId,
            "send" : true,
            "from_id" : fromId,
            "texte" : texte,
            "date_message": Timestamp(), // Date Firebase
            "url_photo" : urlPhoto,
            "to_id" : toId,
            "date_sort": Date() // Date Swift utilisé pour le tri dans BubblesView
        ]
        do {
            try await document.setData(data, merge: false)
        } catch {
            print("newMessage: \(error)")
        }
    }
    
    
    // Listener sur les messages
    func addlistenerMessages(salonId: String, completion: @escaping (_ messages: [Messages]) -> Void) {
        messagesCollection(salonId: salonId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("no documents")
                return
            }
            let messages: [Messages] = documents.compactMap({ try? $0.data(as: Messages.self) })
            completion(messages)
        }
    }

    // Charger les messages du salon
    func getMessages(salonId: String, currentUserId: String) async throws -> [Messages] {
        let snapshot = try await messagesCollection(salonId: salonId)
            .whereField("salon_id", isEqualTo: salonId)
            .getDocuments()

        var messages = [Messages]()

        for doc in snapshot.documents {
            var msg = try doc.data(as: Messages.self)
            if currentUserId == msg.fromId {
                msg.send = true
            } else {
                msg.send = false
            }
            messages.append(msg)

        }
        return messages
    }
}

