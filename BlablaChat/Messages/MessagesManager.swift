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
    
    // Collections -----------------------------------------
    private let salonsCollection = dbFS.collection("Salons")
    private let messagesCollection = dbFS.collection("messages")
    private let subUsersCollection = dbFS.collection("subUsers")
    
    // Salons
    private func allSalonsCollection() -> CollectionReference {
        salonsCollection
    }
    private func salonDocument(salonId: String) -> DocumentReference {
        salonsCollection.document(salonId)
    }
    
    // Sous-collection Messages ----------------------------------------
    private func messagesCollection(salonId: String) -> CollectionReference {
        return salonDocument(salonId: salonId).collection("messages")
    }
    private func messageDocument(id: String) -> DocumentReference {
        return messagesCollection.document(id)
    }

    // Sous-collection subUsers -----------------------------------
    private func subUsersCollection(salonId: String) -> CollectionReference {
        return salonDocument(salonId: salonId).collection("subUsers")
    }
    private func subUsersDocument(userId: String) -> DocumentReference {
        return subUsersCollection.document(userId)
    }
    
    // ---------------------------------------------------------------------------
    
    // Création d'un nouveau message dans un salon
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

    // Tous les messages d'un salon
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
    
    // Get le salonId du currentUser et du contactId uniquement
    func getSalonId(currentId: String, contactId: String) async throws -> String {
        
        var allSalons: [Salons] = []
        
        // Tous les salons
        let snapshot = try await allSalonsCollection().getDocuments()
        for doc in snapshot.documents {
            let unSalon = try doc.data(as: Salons.self)
            allSalons.append(unSalon)
        }
        if allSalons.isEmpty {
            return("")
        }

       // Les subUsers d'un salon
        var subUsers: [SubUsers] = []
        
        for salon in allSalons {
            subUsers = []
            // Les subUsers du salon contenant currentId et contactId
            let query = try await subUsersCollection(salonId: salon.salonId)
                .whereField("userId", isEqualTo: currentId)
                .whereField("userId", isEqualTo: contactId)
                .getDocuments()
            
            for sub in query.documents {
                let unSubUser = try sub.data(as: SubUsers.self)
                subUsers.append(unSubUser)
            }
            if subUsers.count == 2 {
                if subUsers.contains(where: { $0.userId == currentId }) && subUsers.contains(where: { $0.userId == contactId }) {
                    return salon.salonId
                }
            }
        }
        return("")
    }
    
    func newTwoSubUsers(salonId: String, currendId: String, contactId: String) async throws {
        for item in [currendId, contactId] {
            let document = subUsersCollection(salonId: salonId).document()
            let documentId = document.documentID
            
            let data: [String:Any] = [
                "id" : documentId,
                "salon_id" : salonId,
                "userId": item,
            ]
            do {
                try await document.setData(data, merge: false)
            } catch {
                print("newMessage: \(error)")
            }
        }
    }
}

