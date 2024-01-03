//
//  FirebaseManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

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
    
    func createUserProfile(userId: String, email: String) {
        let userData = ["uid": userId, "email": email]
        userDocument(userId: userId).setData(userData)
    }
    
    func updateProfileImage(userId: String, image: UIImage) {
        let data: [String:Any] = [
            "imagelien" : image
        ]
        print("name update: \(image)") // Ok
        userDocument(userId: userId).updateData(data)
    }
    
}
