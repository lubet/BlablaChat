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
    
    // Voir si le contact et le user existe déjà dans Salons-Users, la paire ne devrait exister qu'une fois ou ne pas exister
    func searchSalonUsers(contactId: String, userId: String) async -> String {
        do {
            let salonsUsersSnapshot = try await SalonsUsersCollection.whereFilter(Filter.orFilter([
                Filter.whereField("userId", isEqualTo: userId),
                Filter.whereField("userId", isEqualTo: contactId)
                ]))
                .getDocuments()
            
            for duo in salonsUsersSnapshot.documents {
                let duo = try duo.data(as: Salons_Users.self)
                let salonId = duo.salonId
                print("searchSalonUsers - La pair \(contactId)-\(userId) existe")
                return salonId
            }
        } catch {
            print("searchSalonUsers - Error getting documents from Salons-Users: \(error)")
        }
        print("searchSalonUsers - La paire n'existe pas dans Salons-Users")
        print("searchSalonUsers \(contactId) \(userId)")
        return ""
    }
    
    // Création d'un nouveau salon
    func newSalon() async throws -> String {
        let userRef = SalonsCollection.document()
        let docId = userRef.documentID
        
        let data: [String:Any] = [
            "salon_id" : docId,
            "date_created" : Timestamp()
        ]
        try await userRef.setData(data, merge: false)
        return docId
    }

    // Création d'un enreg user et d'un enreg contact dans Salons-Users avec le mêm n° de salon.
    func newSalonsUsers(salonId: String, contactId: String, userId: String) async throws {
        // Le contact
        let userRef = SalonsUsersCollection.document()
        let data1: [String:Any] = [
            "salon_id" : salonId,
            "user_id" : contactId
        ]
        do {
           try  await userRef.setData(data1, merge: false)
        }
        catch {
            print("newSalonUser-contact: \(error)")
        }
        
        // Le user
        let userRef2 = SalonsUsersCollection.document()
        
        let data2: [String:Any] = [
            "salon_id" : salonId,
            "user_id" : userId
        ]
        do {
            try await userRef2.setData(data2, merge: false)
        } catch {
            print("newSalonUser-user: \(error)")
        }
    }
    
    func newMessage(salonId: String, fromId: String, texte: String) async throws {
        let userRef = MessagesCollection.document()
        
        let data: [String:Any] = [
            "salon_id" : salonId,
            "from_id" : fromId,
            "texte" : texte
        ]
        do {
            try await userRef.setData(data, merge: false)
        } catch {
            print("newMessage: \(error)")
        }
    }
    
    // Get mes Messages
    func getMessages(userId: String) async throws -> [Messages] {
        let snapshot = try await Firestore.firestore().collection("Messages").getDocuments()
        
        var messages = [Messages]()
        
        for document in snapshot.documents {
            let msg = try document.data(as: Messages.self)
            if msg.fromId != userId {
                messages.append(msg)
            }
        }
        return messages
    }

}

