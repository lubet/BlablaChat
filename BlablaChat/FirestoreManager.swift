//
//  FirebaseManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser: Codable {
    let userId: String
    let email : String?
    let dateCreated: Date?
    let imageLink: String?
    
    // Init du document à partir des données de l'authentification auxquelles on ajoute la date de création et le champ premium
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
}

final class FirestoreManager {
    
    static let shared = FirestoreManager()
    init() { }
    
    /// References --------------------------------------------------------------------------------------------
    
    // Reference la collection "users"
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // Reference un user
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
    
    // Reference tous les users
    private func usersCollection() -> CollectionReference {
        return userCollection
    }
    
    // codage -----------------------------------------------
    
    // encodage JSON pour créer l'utilisateur dans la base - createNewUser
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    // decodage du JSON pour downloader le user à partir de la database - getUser
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    // fonctions ----------------------------------------------
    
    func createDbUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    // Téléchargement du profile d'un user de la base  avec decodage JSON vers local - Meilleure méthode
    func getUser(userId: String) async throws -> DBUser {
        let dbUser = try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
        print("imageLink: \(dbUser.imageLink ?? "")")
        return dbUser
    }

    
//    // Création d'un document user dans la BDD
//    func createDbUser(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: false)
//    }
        
//    func updateImagePath(userId: String, path: String) async throws { // maj image DBuser et FireStore
//        let data: [String:Any] = [
//            DBUser.CodingKeys.imageLink.rawValue : path
//        ]
//        try await userDocument(userId: userId).updateData(data)
//    }
}
