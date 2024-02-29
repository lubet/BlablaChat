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

struct Group_member: Identifiable, Codable {
    let id: String
    let contact_id: String
    let room_id: String
    let date_created: Timestamp
    
    init(
        id:String,
        contact_id:String,
        room_id:String,
        date_created:Timestamp
    ) {
        self.id = id
        self.contact_id = contact_id
        self.room_id = room_id
        self.date_created = Timestamp()
    }
}

struct Room: Identifiable, Codable {
    let room_id: String
    let room_name: String
    let dateCreated: Timestamp
    let last_message: String
    
    var id: String {
        room_id
    }
    
    enum CodingKeys: String, CodingKey {
        case room_id
        case room_name
        case dateCreated = "date_created"
        case last_message
    }
    
    init(
        room_id:String,
        room_name:String,
        dateCeated:Timestamp,
        last_message:String
    ) {
        self.room_id = room_id
        self.room_name = room_name
        self.dateCreated = Timestamp()
        self.last_message = last_message
    }
}

struct Message: Identifiable, Codable {
    let id:String
    let from_id:String
    let to_id: String
    let message_text:String
    let date_send:Timestamp
    let room_id:String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case from_id = "from_id"
        case to_id = "to_id"
        case message_text = "message_text"
        case date_send = "date_send"
        case room_id = "room_id"
    }
    
    init(
        id: String,
        from_id: String,
        to_id: String,
        message_text: String,
        date_send: Timestamp,
        room_id: String
    ) {
        self.id = id
        self.from_id = from_id
        self.to_id = to_id
        self.message_text = message_text
        self.date_send = Timestamp()
        self.room_id = room_id
    }
}

final class NewContactManager {
    
    static let shared = NewContactManager()
    
    init() { }
    
    // ---------------------------------------------------
    private let DBUserCollection = dbFS.collection("users")
    
    private func userDocument(email:String) -> DocumentReference {
        return DBUserCollection.document(email)
    }
    
    // ---------------------------------------------------------------
    private let groupMemberCollection = dbFS.collection("group_member")
    
    // -----------------------------------------------------------------
    private let roomCollection = dbFS.collection("room")
    
    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }
                
    private let messageCollection = dbFS.collection("message")
    
    //-----------------------------------------------------------------
    
    // Recherche du contact dans la base "users"
    func searchContact(email: String) async throws -> String {
        do {
            let querySnapshot = try await DBUserCollection
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: DBUser.self)
                if (user.email == email) {
                    print("searchContact trouvé:\(email)")
                    return user.userId
                }
            }
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
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
            "date_created" : Timestamp()
        ]
        try await userRef.setData(data, merge: false)
        
        print("createUser user_id:\(user_id)")
        return user_id
    }
    
    // Recherche d'une éventuelle conversation_id commune à user_id et à contact_id
    func searchDuo(user_id:String, contact_id:String) async throws -> String {
        
        print("searchDuo1: user_id:\(user_id)-contact_id:\(contact_id)")
        
        let room: String = ""
        
        var set_user:Set<String> = []
        var set_contact:Set<String> = []

        // Set des room_id's du user_id
        do {
            let querySnapshot = try await dbFS.collection("group_member").whereField("contact_id", isEqualTo: user_id).getDocuments()
            for document in querySnapshot.documents {
                let membre_user = try document.data(as: Group_member.self)
                set_user.insert(membre_user.room_id)
            }
            if (set_user.count == 0) {
                print("Pas de room dans member pour set_user")
                return room // pas de room
            }
        } catch {
            print("Error getting documents user_id: \(error)")
        }

        // Set des room_id's du contact_id
        do {
            let contactSnapshot = try await groupMemberCollection
                .whereField("contact_id", isEqualTo: contact_id)
                .getDocuments()
            for document in contactSnapshot.documents {
                let membre_contact = try document.data(as: Group_member.self)
                set_contact.insert(membre_contact.room_id)
            }
            if (set_contact.count == 0) {
                print("Pas de room dans member pour set_contact")
                return room // pas de room
            }
        } catch {
            print("Error getting documents contact_id: \(error.localizedDescription)")
        }

        print("searchDuo3 set_user:\(set_user)-set_contact:\(set_contact)")
        
        // intersection des deux sets pour trouver le room en commun
        let inter = set_user.intersection(set_contact)
        print("inter:\(inter)")
        
        if (inter.count != 1) { // Pas une room_id commune aux croom_id de user_id et de contact_id
            print("Pas un room commun trouvée") // -> Créer deux enregs un: user_id room_id l'autre: contact_id room_id
            return room
        } else {
            print("Un room commun a été trouvée:\(inter.first ?? "")")
            return inter.first ?? ""
        }
    }
    
    func createRoom(name: String) async throws -> String {
        let roomRef = roomCollection.document()
        let room_id = roomRef.documentID
        
        let data: [String:Any] = [
            "room_id" : room_id,
            "room_name": name,
            "date_created" : Timestamp(),
            "last_message" : ""
        ]
        try await roomRef.setData(data, merge: false)
        
        print("createRoom:\(room_id)")
        return room_id
    }
    
    func createGroupMembers(room_id: String, user_id:String, contact_id:String) async throws {
        
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
                "room_id": room_id,
                "date_created" : Timestamp(),
                "last_message" : ""
            ]
            try await memberRef.setData(data, merge: false)
        }
    }
    
    func createMessage(from_id: String, to_id: String, message_text: String, room_id: String) async throws {
        let messageRef = messageCollection.document()
        let message_id = messageRef.documentID
        
        let data: [String:Any] = [
            "id": message_id,
            "from_id": from_id,
            "to_id": to_id,
            "message_text": message_text,
            "date_send": Timestamp(),
            "room_id": room_id
        ]
        try await messageRef.setData(data, merge: false)
    }
}
