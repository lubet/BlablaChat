//
//  FirebaseManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


final class UsersManager {
    
    static let shared = UsersManager()
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
    
    func createDbUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func updateImagePath(userId: String, path: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.avatarLink.rawValue : path,
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    //
    func getAllUsers() async throws -> [DBUser] {
        let authUser = try AuthManager.shared.getAuthenticatedUser()
        let user_id = authUser.uid
        
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
        
        var dbUsers = [DBUser]()
        
        for document in snapshot.documents {
            let user = try document.data(as: DBUser.self)
            if user.userId != user_id {
                dbUsers.append(user)
            }
        }
        return dbUsers
    }
    
    // Recherche de l'avatar dans "users".
    // Cas des SignUP car leur avatar se trouve dans "users"
    // mais pas dans "rooms" car ils n'ont pas encore de room qui n'est créer qu'à la création du premier message
    func getAvatar(contact_id: String) async throws -> String {
        do {
            let querySnapshot = try await userCollection
                .whereField("user_id", isEqualTo: contact_id)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: DBUser.self)
                if (user.userId == contact_id) {
                    return user.avatarLink ?? ""
                }
            }
        } catch {
            print("getAvatar - Error getting documents: \(error)")
        }
        print("getAvatar: non trouvé pour contact-id: \(contact_id)")

        return ""
    }
}


