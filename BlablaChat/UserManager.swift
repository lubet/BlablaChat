//
//  FirebaseManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable, Identifiable {
    let userId: String
    let email : String?
    let dateCreated: Date?
    let imageLink: String?
    
    var id: String {
        userId
    }
    
    // Init du document à partir des données de l'authentification auxquelles on ajoute la date de création et le lien de l'image
    init(auth: AuthUser) {
        self.userId = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        self.imageLink = nil
    }
    
    init(
        userId: String,
        email : String? = nil,
        dateCreated: Date? = nil,
        imageLink: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.dateCreated = dateCreated
        self.imageLink = imageLink
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case dateCreated = "date_created"
        case imageLink = "image_link"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.imageLink, forKey: .imageLink)
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.imageLink = try container.decodeIfPresent(String.self, forKey: .imageLink)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // user
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
    
    // users
    private func usersCollection() -> CollectionReference {
        return userCollection
    }
    
    
    //
    func createDbUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    //
    func getUser(userId: String) async throws -> DBUser {
        return try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    //
    func updateImagePath(userId: String, path: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.imageLink.rawValue : path,
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    //
    func getAllUsers() async throws -> [DBUser] {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
        
        var dbUsers = [DBUser]()
        
        for document in snapshot.documents {
            let user = try document.data(as: DBUser.self)
            // print("user: \(user)")
            dbUsers.append(user)
        }
        return dbUsers
    }
    
    // Messages -----------------------------------------------------------------------
    
    private func userMessagesCollection(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("messages")
    }
    
    private func userMessageDocument(userId: String, messageId: String) -> DocumentReference {
        userMessagesCollection(userId: userId).document(messageId)
    }
    
    func addUserMessage(userId: String, from: String, to: String, texte: String) async throws {
        let document = userMessagesCollection(userId: userId).document()
        let documentId = document.documentID
                
        let data: [String:Any] = [
            UserMessage.CodingKeys.id.rawValue : documentId,
            UserMessage.CodingKeys.id.rawValue : from,
            UserMessage.CodingKeys.id.rawValue : to,
            UserMessage.CodingKeys.id.rawValue : texte,
            UserMessage.CodingKeys.id.rawValue : Timestamp()
        ]
        try await document.setData(data, merge: false)
    }
    
    func removeUserMessage(userId: String, messageId: String) async throws {
        try await userMessageDocument(userId: userId, messageId: messageId).delete()
    }
    
    
}

struct UserMessage: Codable, Identifiable {
    let id: String
    let from: String
    let to: String
    let texte: String
    let dateCreated: Date
    
    init(
        id: String,
        from : String,
        to: String,
        texte: String,
        dateCreated: Date
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.texte = texte
        self.dateCreated = dateCreated
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case from = "from"
        case to = "to"
        case texte = "texte"
        case dateCreated = "date_created"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.from = try container.decode(String.self, forKey: .from)
        self.to = try container.decode(String.self, forKey: .to)
        self.texte = try container.decode(String.self, forKey: .texte)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.from, forKey: .from)
        try container.encode(self.to, forKey: .to)
        try container.encode(self.texte, forKey: .texte)
        try container.encode(self.dateCreated, forKey: .dateCreated)
    }
    
}
