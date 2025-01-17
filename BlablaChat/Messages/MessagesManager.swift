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
    
    private let SalonsUsersCollection = dbFS.collection("Salons_Users")
    
    // ---------------------------------------------------------------
    
    private let SalonsCollection = dbFS.collection("Salons")
    
    // Voir si le contact et le user existe déjà dans Salons-Users, la paire ne devrait exister qu'une fois ou ne pas exister
    func searchSalonsUsers(contactId: String, userId: String) async throws -> String {
        do {
            
            let query = try await SalonsUsersCollection.whereFilter(Filter.orFilter([
                Filter.whereField("user_id", isEqualTo: contactId),
                Filter.whereField("user_id", isEqualTo : userId)
                ]))
                .getDocuments()
            
            for doc in query.documents {
                let duo = try doc.data(as: Salons_Users.self)
                let salon_id = duo.salonId
                print("searchSalonUsers - La pair \(contactId)-\(userId) existe")
                print(salon_id)
            }
        } catch {
            print("searchSalonUsers - Error getting documents from Salons_Users: \(error)")
        }
        print("searchSalonUsers - La paire n'existe pas dans Salons_Users")
        print("searchSalonUsers \(contactId) \(userId)")
        return ""
    }
    
    // OK
    func essai() async {
        do {
            let querySnapshot = try await SalonsUsersCollection.whereField("user_id", isEqualTo: "oGemyMofBw1At8sC2lcX")
                .getDocuments()
            for document in querySnapshot.documents {
                print("essai*****:\(document.documentID) => \(document.data())")
            }
        } catch {
            print("Error getting documents: \(error)")
        }
        print("Pas trouvé **********")
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
            "id" : UUID().uuidString,
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
            "id" : UUID().uuidString,
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

