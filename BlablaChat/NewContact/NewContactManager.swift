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

struct Member: Identifiable, Codable {
    let id: String
    let from_id: String
    let to_id: String
    let room_id: String
    let date_created: Timestamp
    
    init(
        id: String,
        from_id: String,
        to_id: String,
        room_id: String,
        date_created:Timestamp
    ) {
        self.id = id
        self.from_id = from_id
        self.to_id = to_id
        self.room_id = room_id
        self.date_created = Timestamp()
    }
}

struct Room: Identifiable, Codable {
    let room_id: String
    let room_name: String
    let dateCreated: Timestamp
    let last_message: String
    let date_message: Timestamp
    let from_message: String
    
    var id: String {
        room_id
    }
    
    enum CodingKeys: String, CodingKey {
        case room_id
        case room_name
        case dateCreated = "date_created"
        case last_message
        case date_message
        case from_message
    }
}

struct Message: Identifiable, Codable {
    let id:String
    let from_id:String
    let to_id: String
    let message_text:String
    let date_send:Timestamp
    let room_id:String
    let image_link:String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case from_id = "from_id"
        case to_id = "to_id"
        case message_text = "message_text"
        case date_send = "date_send"
        case room_id = "room_id"
        case image_link = "image_link"
    }
    
    init(
        id: String,
        from_id: String,
        to_id: String,
        message_text: String,
        date_send: Timestamp,
        room_id: String,
        image_link: String?
    ) {
        self.id = id
        self.from_id = from_id
        self.to_id = to_id
        self.message_text = message_text
        self.date_send = date_send
        self .room_id = room_id
        self.image_link = image_link
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
    private let MemberCollection = dbFS.collection("members")
    
    // -----------------------------------------------------------------
    private let roomCollection = dbFS.collection("rooms")
    
    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }
           
    // Collection messages - sous collection de rooms
    private func messageCollection(room_id: String) -> CollectionReference {
        roomDocument(room_id: room_id).collection("messages")
    }
    
    // Document message
    private func messageDocument(room_id: String, message_id: String) -> DocumentReference {
        messageCollection(room_id: room_id).document(message_id)
    }
    
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
            print("searchContact - Error getting documents: \(error.localizedDescription)")
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
    
    // Renvoie le room_id du duo from/to ou to/fom si existant dans members
    func searchDuo(user_id: String, contact_id: String) async throws -> String {

        do {
            let memberSnapshot = try await MemberCollection.whereFilter(Filter.orFilter([
                Filter.andFilter([
                    Filter.whereField("from_id", isEqualTo: user_id),
                    Filter.whereField("to_id", isEqualTo: contact_id)
                ]),
                Filter.andFilter([
                    Filter.whereField("from_id", isEqualTo: contact_id),
                    Filter.whereField("to_id", isEqualTo: user_id)
                ])
            ])
            ).getDocuments()
            
            for duo in memberSnapshot.documents {
                let duo = try duo.data(as: Member.self)
                let roomId = duo.room_id
                print("searchDuo - room_id: \(roomId)")
                return roomId
            }
        } catch {
            print("searchDuo - Error getting documents from members: \(error.localizedDescription)")
        }
        print("searchDuo - La paire n'existe pas dans members")
        return ""
    }
    
    // New Room
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
    
    func createMembers(room_id: String, user_id:String, contact_id:String) async throws {
            let memberRef = MemberCollection.document()
            let member_id = memberRef.documentID

        let data: [String:Any] = [
                "id": member_id,
                "from_id": user_id,
                "to_id": contact_id,
                "room_id": room_id,
                "date_created" : Timestamp(),
                "last_message" : ""
            ]
            try await memberRef.setData(data, merge: false)
    }
    
    // Création du message et maj du dernier message de Room avec le message
    func createMessage(from_id: String, to_id: String, message_text: String, room_id: String, image_link: URL) async throws {
        let messageRef = roomDocument(room_id: room_id).collection("messages").document()
        let message_id = messageRef.documentID
        
        let dateMessage = Timestamp()
        
        let data: [String:Any] = [
            "id": message_id,
            "from_id": from_id,
            "to_id": to_id,
            "message_text": message_text,
            "date_send": dateMessage,
            "room_id": room_id,
            "image_link": image_link
        ]
        try await messageRef.setData(data, merge: false)
        
        // Maj dernier message dans Room
        let roomRef = roomDocument(room_id: room_id)

        let dataRoom: [String:Any] = [
            "last_message": message_text,
            "date_message": dateMessage,
            "from_message": from_id,
            "image_link": image_link
        ]
        
        try await roomRef.setData(dataRoom, merge: true)
    }
}
