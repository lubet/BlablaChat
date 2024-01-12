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
    
    struct UserMessage: Codable, Identifiable {
        let messageId: String
        let message: String
        let received: Bool
        let dateCreated: Date
        
        var id: String {
            messageId
        }

        enum CodingKeys: String, CodingKey {
            case messageId = "message_id"
            case message = "message"
            case received = "received"
            case dateCreated = "date_created"
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: UserManager.UserMessage.CodingKeys.self)
            try container.encode(self.messageId, forKey: UserManager.UserMessage.CodingKeys.messageId)
            try container.encode(self.message, forKey: UserManager.UserMessage.CodingKeys.message)
            try container.encode(self.received, forKey: UserManager.UserMessage.CodingKeys.received)
            try container.encode(self.dateCreated, forKey: UserManager.UserMessage.CodingKeys.dateCreated)
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<UserManager.UserMessage.CodingKeys> = try decoder.container(keyedBy: UserManager.UserMessage.CodingKeys.self)
            self.messageId = try container.decode(String.self, forKey: UserManager.UserMessage.CodingKeys.messageId)
            self.message = try container.decode(String.self, forKey: UserManager.UserMessage.CodingKeys.message)
            self.received = try container.decode(Bool.self, forKey: UserManager.UserMessage.CodingKeys.received)
            self.dateCreated = try container.decode(Date.self, forKey: UserManager.UserMessage.CodingKeys.dateCreated)
        }
        
    }
    
    func addUserMessage(userId: String, message: String, received: Bool) {
        let document = userMessagesCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data : [String:Any] = [
            "messageId" = documentId,
            "message" = message,
            "received" = received
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func removeUserMessage(userId: String, messageId: String) {
        try await userMessageDocument(userId: userId, messageId: messageId).delete()
    }
}
