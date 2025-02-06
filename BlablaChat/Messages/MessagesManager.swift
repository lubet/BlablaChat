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
    

    // Salons ----------------------------------------------------
    private let salonsCollection = dbFS.collection("Salons")
    private func salonDocument(salonId: String) -> DocumentReference {
        salonsCollection.document(salonId)
    }
    
    // Salons/Messages
    private let messagesCollection = dbFS.collection("Messages")
    // Tous les messages d'un salon
    private func messagesCollection(salonId: String) -> CollectionReference {
        return salonDocument(salonId: salonId).collection("Messages")
    }
    
    // Salons/Users ------------------------------
    private let usersCollection = dbFS.collection("Users")
    // Tous les users d'un salon
    private func usersSalon(salonId: String) -> CollectionReference {
        return salonDocument(salonId: salonId).collection("Users")
    }
    
    // Membres
    private let membresCollection = dbFS.collection("Membres")
   
    private func membreDocument(salonId: String, contactId: String, userId: String) -> DocumentReference {
        return membresCollection.document(salonId)
    }
    
    
    // ------------------------------------------------------------------------------------
    
    // Création d'un nouveau salon
    func newSalon(last_message: String, contactId: String) async throws -> String {
        let salonRef = salonsCollection.document()
        let docId = salonRef.documentID
        
        let data: [String:Any] = [
            "salon_id" : docId,
            "last_message": last_message,
            "date_created" : Timestamp(),
            "contact_id": contactId
        ]
        try await salonRef.setData(data, merge: false)
        return docId
    }
    
    func newMessage(salonId: String, fromId: String, texte: String, urlPhoto: String) async throws {
        let document = messagesCollection(salonId: salonId).document()
        let documentId = document.documentID
        
        let data: [String:Any] = [
            "id" : documentId,
            "salon_id" : salonId,
            "send" : true,
            "from_id" : fromId,
            "texte" : texte,
            "date_message": Timestamp(),
            "url_photo" : urlPhoto
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

    // Extrait les messages du salon
    func getMessages(salonId: String) async throws -> [Messages] {
        let snapshot = try await messagesCollection(salonId: salonId)
            .whereField("salon_id", isEqualTo: salonId)
            .getDocuments()

        var messages = [Messages]()

        for doc in snapshot.documents {
            let msg = try doc.data(as: Messages.self)
            messages.append(msg)

        }
        return messages
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

    func majLastMessageSalons(salonId: String, lastMessage: String) async throws {
        let data: [String:Any] = [
            Salons.CodingKeys.lastMessage.rawValue : lastMessage,
        ]
        try await salonDocument(salonId: salonId).updateData(data)
    }

    
// Voir si user et contact ont le même salonId
//    func searchSalonsUsers(contactId: String, userId: String) async throws -> String {
//
//        // Tous les mêmes contactId
//        do {
//            let lesContactId = try await usersCollaction.whereField("user_id", isEqualTo: contactId)
//                .getDocuments()
//            let lesUserId = try await usersCollaction.whereField("user_id", isEqualTo: userId)
//                .getDocuments()
//            for oneContact in lesContactId.documents {
//                let cont = try oneContact.data(as: DBUser.self)
//                let contactSalonId = cont.userId
//                for oneUser in lesUserId.documents {
//                    let oneus = try oneUser.data(as: DBUser.self)
//                    if (oneus.userId == contactSalonId) {
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

