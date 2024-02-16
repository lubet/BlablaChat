//
//  NewContactManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/02/2024.
//
// Les contacts c'est "DBUser"

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let dbFS = Firestore.firestore()

struct group_member: Identifiable, Codable {
    let id: String
    let contact_id: String
    let conversation_id: String
    let date_created: Timestamp
    
    init(
        id:String,
        contact_id:String,
        conversation_id:String,
        date_created:Timestamp
    ) {
        self.id = id
        self.contact_id = contact_id
        self.conversation_id = conversation_id
        self.date_created = Timestamp()
    }
}

struct conversation: Identifiable, Codable {
    let id:String
    let conversation_id:String
    let conversation_name:String
    let date_created:Timestamp
    let last_message:String
    
    init(
        id:String,
        conversation_id:String,
        conversation_name:String,
        date_created:Timestamp,
        last_message:String
    ) {
        self.id = id
        self.conversation_id = conversation_id
        self.conversation_name = conversation_name
        self.date_created = Timestamp()
        self.last_message = last_message
    }
}

struct message: Identifiable, Codable {
    let id:String
    let from_id:String
    let message_text:String
    let date_send:Timestamp
    let conversation_id:String
    
    init(
        id:String,
        from_id:String,
        message_text:String,
        date_send:Timestamp,
        conversation_id:String
    ) {
        self.id = id
        self.from_id = from_id
        self.message_text = message_text
        self.date_send = Timestamp()
        self.conversation_id = conversation_id
    }
}

final class NewContactManager {
    
    static let shared = NewContactManager()
    
    init() { }
    
    private let DBUserCollection = dbFS.collection("users")
    
    private func userDocument(email:String) -> DocumentReference {
        return DBUserCollection.document(email)
    }
    
    private let groupMemberCollection = dbFS.collection("group_member")
    
    
    // Recherche du contact dans la base "users"
    func searchContact(email:String) async throws -> DBUser {
        return try await userDocument(email: email).getDocument(as: DBUser.self)
    }
    
    // Création du contact dans la base "users"
    func createContact(email:String) async throws -> String {
        let ContactRef = userDocument(email: email)
        let Contact_id = ContactRef.documentID
        
        let data: [String:Any] = [
            "user_id" : Contact_id,
            "email": email,
            "dateCreated" : Timestamp()
        ]
        try await ContactRef.setData(data, merge: false)
        
        return Contact_id
    }
    
    // Recherche du duo ayant la même conversation
    func searchDuo(user_id:String, contact_id:String) async throws -> [group_member] {
        let tab_user: [group_member]
        let tab_contact: [group_member]
        
        
        
        do {
            let querySnapshot = try await groupMemberCollection
                .whereField("contact_id", isEqualTo: user_id)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let membre = try document.data(as: group_member.self)
                tab_user.append(membre)
            }
        } catch {
            print("Erreur getChatsId: \(error)")
        }
        return group_member
        
    }
}
