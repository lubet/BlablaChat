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
    
    private let conversationCollection = dbFS.collection("conversation")
    
    //-----------------------------------------------------------------
    
    // Recherche du contact dans la base "users"
    func searchContact(email: String) async throws -> String {
        let querySnapshot = try await DBUserCollection
            .whereField("email", isEqualTo: email)
            .getDocuments()
        
        for document in querySnapshot.documents {
            let user = try document.data(as: DBUser.self)
            if (user.email == email) {
                print("searchContact trouvé:\(email)")
                return user.userId
            } else {
                continue
            }
        }
        print("searchContact non trouvé")
        return ""
    }
    
    // Création du contact dans la base "users"
    func createUser(email:String) async throws -> String {
        let userRef = DBUserCollection.document()
        let user_id = userRef.documentID

        let data: [String:Any] = [
            "user_id" : user_id,
            "email": email,
            "dateCreated" : Timestamp()
        ]
        try await userRef.setData(data, merge: false)
        
        print("createUser user_id:\(user_id)")
        return user_id
    }
    
    // Recherche d'une éventuelle conversation_id commune à user_id et à contact_id
    func searchDuo(user_id:String, contact_id:String) async throws -> String {
        
        print("searchDuo: user_id:\(user_id)-contact_id:\(contact_id)")
        
        let conversation: String = ""
        
        var set_user:Set<String> = []
        var set_contact:Set<String> = []

        // Set des conversation_id's du user_id
        let querySnapshot = try await groupMemberCollection
            .whereField("contact_id", isEqualTo: user_id)
            .getDocuments()
        for document in querySnapshot.documents {
            let membre = try document.data(as: group_member.self)
            set_user.insert(membre.conversation_id)
        }
        if (set_user.count == 0) {
            print("Pas de conversation dans member pour set_user")
            return conversation // pas conversation
        }
        
        // Set des conversation_id's du contact_id
        let contactSnapshot = try await groupMemberCollection
            .whereField("contact_id", isEqualTo: contact_id)
            .getDocuments()
        for document in contactSnapshot.documents {
            let membre = try document.data(as: group_member.self)
            set_contact.insert(membre.conversation_id)
        }
        if (set_contact.count == 0) {
            print("Pas de conversation dans member pour set_contact")
            return conversation // pas de conversation
        }

        // intersection des deux sets pour trouver la conversation en commun
        let inter = set_user.intersection(set_contact)
        if (inter.count == 2) { // 2 valeurs: conversation_id de user_id et la même conversation_id mais de contact_id
            print("Une conversation commune a été trouvée:\(inter.description)")
            return inter.description
        } else {
            print("Pas un conversation commune trouvée") // -> Créer deux enregs un: user_id conversation_id l'autre: contact_id conversation_id
            return conversation
        }
    }
    
    func createConversation(name: String) async throws -> String {
        let conversationRef = conversationCollection.document()
        let conversation_id = conversationRef.documentID
        
        let data: [String:Any] = [
            "conversation_id" : conversation_id,
            "conversation_name": name,
            "dateCreated" : Timestamp(),
            "last_message" : ""
        ]
        try await conversationRef.setData(data, merge: false)
        
        print("createConversation:\(conversation_id)")
        return conversation_id
    }
    
    func createGroupMembers(conversation_id: String, user_id:String, contact_id:String) async throws {
        
        for x in 0..<2 {
            let memberRef = groupMemberCollection.document()
            let member_id = memberRef.documentID
            var user:String = ""
            
            if x == 0 {
                user = user_id
            } else {
                user = contact_id
            }
            let data: [String:Any] = [
                "id": member_id,
                "contact_id" : user,
                "conversation_id": conversation_id,
                "dateCreated" : Timestamp(),
                "last_message" : ""
            ]
            try await memberRef.setData(data, merge: false)
        }
    }
}
