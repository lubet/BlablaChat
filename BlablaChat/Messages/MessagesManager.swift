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
    
    // --------------------------------------------------------------
    // private let SalonsUsersCollection = dbFS.collection("Salons_Users")
    // ---------------------------------------------------------------
    

    // Salons
    private let salonsCollection = dbFS.collection("Salons")

    private func salonDocument(salonId: String) -> DocumentReference {
        salonsCollection.document(salonId)
    }
    
    // Messages ----------------------------------
    
    // Tous les messages
    private let messagesCollection = dbFS.collection("Messages")

    // Tous les messages d'un salon
    private func messagesCollection(salonId: String) -> CollectionReference {
        return salonDocument(salonId: salonId).collection("Messages")
    }

    
    //
//    private func messageDocument(salonId: String, messageId: String) -> DocumentReference {
//        return messagesCollection(salonId: salonId).document(messageId)
//    }
//
//    private func messageDocument(salonId: String) -> DocumentReference {
//        return messagesCollection(salonId: salonId).document()
//    }
//
//    private func messageDocument(userId: String) -> DocumentReference {
//        return messagesCollection.document(userId)
//    }
    
    
    
    // ------------------------------------------------------------------------------------
    
    // Création d'un nouveau salon
    func newSalon() async throws -> String {
        let userRef = salonsCollection.document()
        let docId = userRef.documentID
        
        let data: [String:Any] = [
            "salon_id" : docId,
            "date_created" : Timestamp()
        ]
        try await userRef.setData(data, merge: false)
        return docId
    }
    
    func newMessage(salonId: String, fromId: String, texte: String) async throws {
        let document = messagesCollection(salonId: salonId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "salon_id" : salonId,
            "from_id" : fromId,
            "texte" : texte,
            "date_message": Timestamp()
        ]
        do {
            try await document.setData(data, merge: false)
        } catch {
            print("newMessage: \(error)")
        }
    }

    // Get mes Messages
    func getMessages(fromId: String) async throws -> [Messages] {
        let snapshot = try await messagesCollection.whereField("fromId", isEqualTo: fromId)
            .getDocuments()

        var messages = [Messages]()

        for document in snapshot.documents {
            let msg = try document.data(as: Messages.self)
            print("msg \(msg)")
            messages.append(msg)

        }
        print("fin \(messages)")
        return messages
    }

    
    
    
    
    // -------------------------------------------------------------------------------------
    
     
    // Recherche do salonId commun au contact et au user
//    func searchSalonsUsers(contactId: String, userId: String) async throws -> String {
//        
//        // Tous les mêmes contactId
//        do {
//            let lesContactId = try await SalonsUsersCollection.whereField("user_id", isEqualTo: contactId)
//                .getDocuments()
//            let lesUserId = try await SalonsUsersCollection.whereField("user_id", isEqualTo: userId)
//                .getDocuments()
//            for oneContact in lesContactId.documents {
//                let cont = try oneContact.data(as: Salons_Users.self)
//                let contactSalonId = cont.salonId
//                for oneUser in lesUserId.documents {
//                    let oneus = try oneUser.data(as: Salons_Users.self)
//                    if (oneus.salonId == contactSalonId) {
//                        return contactSalonId
//                    }
//                }
//            }
//        } catch {
//            print("searchSalonUsers-erreurs:\(error)")
//        }
//        print("searchSalonUsers-Pas de n° de salon en commun pour contact et user")
//        return ""
//    }
    
    // OK
//    func essai() async {
//        do {
//            let querySnapshot = try await SalonsUsersCollection.whereField("user_id", isEqualTo: "oGemyMofBw1At8sC2lcX")
//                .getDocuments()
//            for document in querySnapshot.documents {
//                print("essai*****:\(document.documentID) => \(document.data())")
//            }
//        } catch {
//            print("Error getting documents: \(error)")
//        }
//        print("Pas trouvé **********")
//    }

    // Création d'un enreg user et d'un enreg contact dans Salons-Users avec le mêm n° de salon.
//    func newSalonsUsers(salonId: String, contactId: String, userId: String) async throws {
//        // Le contact
//        let userRef = SalonsUsersCollection.document()
//        let docId1 = userRef.documentID
//        
//        let data1: [String:Any] = [
//            "id" : docId1,
//            "salon_id" : salonId,
//            "user_id" : contactId
//        ]
//        do {
//           try  await userRef.setData(data1, merge: false)
//        }
//        catch {
//            print("newSalonUser-contact: \(error)")
//        }
//        
//        // Le user
//        let userRef2 = SalonsUsersCollection.document()
//        let docId2 = userRef2.documentID
//        
//        let data2: [String:Any] = [
//            "id" : docId2,
//            "salon_id" : salonId,
//            "user_id" : userId
//        ]
//        do {
//            try await userRef2.setData(data2, merge: false)
//        } catch {
//            print("newSalonUser-user: \(error)")
//        }
//    }
    
//    func newMessage(salonId: String, fromId: String, texte: String) async throws {
//        let userRef = MessagesCollection.document()
//        let id = userRef.documentID
//        
//        let data: [String:Any] = [
//            "id" : id,
//            "salon_id" : salonId,
//            "from_id" : fromId,
//            "texte" : texte
//        ]
//        do {
//            try await userRef.setData(data, merge: false)
//        } catch {
//            print("newMessage: \(error)")
//        }
//    }
//    
//    // Get mes Messages
//    func getMessages(fromId: String) async throws -> [Messages] {
//        print("*userId: \(from_id)")
//        let snapshot = try await MessagesCollection.whereField("fromId", isEqualTo: fromId)
//            .getDocuments()
//        
//        var messages = [Messages]()
//        
//        for document in snapshot.documents {
//            let msg = try document.data(as: Messages.self)
//            print("msg \(msg)")
//            messages.append(msg)
//            
//        }
//        print("fin \(messages)")
//        return messages
//    }
//    
//    
//    func getMessages(user_id: String, contact_id) {
//        do {
//            let memberSnapshot = try await MessagesCollection.whereFilter(Filter.orFilter([
//                Filter.andFilter([
//                    Filter.whereField("from_id", isEqualTo: user_id),
//                    Filter.whereField("to_id", isEqualTo: contact_id)
//                ]),
//                Filter.andFilter([
//                    Filter.whereField("from_id", isEqualTo: contact_id),
//                    Filter.whereField("to_id", isEqualTo: user_id)
//                ])
//            ])
//            ).getDocuments()
//            
//            for duo in memberSnapshot.documents {
//                let duo = try duo.data(as: Member.self)
//                let roomId = duo.room_id
//                return roomId
//            }
//        } catch {
//            print("searchDuo - Error getting documents from members: \(error)")
//        }
//        print("searchDuo - La paire n'existe pas dans members")
//        return ""
//    }
//
//        
//    }

}

