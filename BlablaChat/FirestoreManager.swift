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
    
    // functions -----------------------------------------------
    
    // Création d'un document user dans la BDD
    func createDbUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func createUserProfile(userId: String, email: String) {
        let userData: [String:Any] = ["uid": userId, "email": email]
        userDocument(userId: userId).setData(userData)
    }
    
//    func updateProfileImage(userId: String, image: UIImage) {
//        let data: [String:Any] = [
//            "imagelien" : image
//        ]
//        print("name update: \(image)") // Ok
//        userDocument(userId: userId).updateData(data)
//    }
    
    func updateImagePath(userId: String, name: String) async throws{
        let data: [String:Any] = [
            "imagelink" : name
        ]
        print("name update: \(name)") // Ok
        try await userDocument(userId: userId).updateData(data)
    }

}
