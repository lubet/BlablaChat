//
//  FirebaseManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

private let dbFS = Firestore.firestore()

final class UsersManager {
    
    static let shared = UsersManager()
    init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    private let DBUserCollection = dbFS.collection("users")
    
    // Fonctions ---------------------------------------------------
    // Retourne le document du user
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
    
    // Retourne la collection users
    private func usersCollection() -> CollectionReference {
        return userCollection
    }
    
    func createDbUser(user: DBUser) async throws {
        try userDocument(userId: user_id).setData(from: user, merge: false)
    }
    
    // Recherche de l'avatar dans "users".
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
    
    // Renvoie le room_id du duo from/to ou to/fom si existant dans members
    
    // Recherche de l'id de mon interlocuteur dans "members"
    
    // New Room pour les contacts (avatar dans "rooms")
    
    
    
    // retourne vrai si le tryptique combiné existe dans "members"
    
    
    // Création du message et maj du dernier message de Room avec le message
    
    // Recherche du room_id dans "members" avec le user_id
    
    // Recherhe de l'email dans "users"
    
    // Création de l'avatar dans "Storage" et maj de l'avatar dans "Users"
    func updateAvatar(userId: String, image: UIImage) async throws {
        let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: userId)
        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        try await UsersManager.shared.updateImagePath(userId: userId, path: lurl.absoluteString) // maj Firestore
        // print("updateAvatar \(lurl)")
    }
}
