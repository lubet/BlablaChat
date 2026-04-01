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
    
    private let DBUserCollection = dbFS.collection("Users")
    private let tokensCollection = dbFS.collection("Tokens")

    private func userDocument(user_id: String) -> DocumentReference {
        return DBUserCollection.document(user_id)
    }
    
    private func userDocument(email:String) -> DocumentReference {
        return DBUserCollection.document(email)
    }

    // Renvoie la sous-collection "Tokens" pour un user
    private func UserTokensCollection(user_id: String) -> CollectionReference {
        return userDocument(user_id: user_id).collection("Tokens")
    }

    // Un document fcmtoken pour un user
    private func tokenDocument(user_id: String, id: String) -> DocumentReference {
        return UserTokensCollection(user_id: user_id).document(id)
    }
    
    // -----------------------------------------------------------------------
    
    // Création du user dans la base "users"
    func createDbUser(user: DBUser) async throws {
        try userDocument(user_id: user.userId).setData(from: user, merge: false)
    }
    
    func updateImagePath(userId: String, path: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.avatarLink.rawValue : path,
        ]
        try await userDocument(user_id: userId).updateData(data)
    }
    
    // Maj de l'id pour le user contact (n'en à pas à sa créeation dans Users car cela a été fait à la crétion du message)
    func updateId(userId: String, Id: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.id.rawValue : Id,
        ]
        try await userDocument(user_id: userId).updateData(data)
    }
    
    // Mise à jour du fcmtoken dans "Users"
//    func updateFCMToken(userId: String, fcmtoken: String) async throws {
//        let data: [String:Any] = [
//            DBUser.CodingKeys.fcmtoken.rawValue : fcmtoken,
//        ]
//        try await userDocument(user_id: userId).updateData(data)
//    }
    
    // Get all users sauf le userSigned
//    func getAllUsers(userId: String) async throws -> [DBUser] {
//        
//        let snapshot = try await DBUserCollection.getDocuments()
//        
//        var dbUsers = [DBUser]()
//        
//        for document in snapshot.documents {
//            let user = try document.data(as: DBUser.self)
//            if user.userId != userId {
//                dbUsers.append(user)
//            }
//        }
//        return dbUsers
//    }
    
    // Recherche de l'avatar dans "users".
    // Cas des SignUP car leur avatar se trouve dans "users"
    // mais pas dans "rooms" car ils n'ont pas encore de room qui n'est créer qu'à la création du premier message
    func getAvatar(contact_id: String) async throws -> String {
        do {
            let querySnapshot = try await DBUserCollection
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
                    return user.userId
                }
            }
        } catch {
            print("searchContact - Error getting documents: \(error)")
        }
        return ""
    }
    
    // Création du contact dans la base "users"
    func createUser(email:String, nom: String, prenom: String) async throws -> String {
        let userRef = DBUserCollection.document()
        let user_id = userRef.documentID
        
        let data: [String:Any] = [
            "avatar_link": "",
            "date_created" : Timestamp(),
            "email": email,
            "id" : user_id,
            "user_id" : user_id,
            "nom" : nom,
            "prenom" : prenom,
            "fcmtoken": ""
        ]
        try await userRef.setData(data, merge: false)
        
        return user_id
    }
    
    
    // Recherhe du user dans "users" avec l'email de connection
    func searchUser(email: String) async throws -> DBUser? {
        do {
            let querySnapshot = try await DBUserCollection
                .whereField("email", isEqualTo: email)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: DBUser.self)
                if (user.email == email) {
                    return user
                }
            }
        } catch {
            print("searchEmail - Error getting documents: \(error)")
        }
        return nil
        
    }
    
    // Recherhe du user dans "users" avec l'email de connection
    func searchUser(userId: String) async throws -> DBUser? {
        do {
            let querySnapshot = try await DBUserCollection
                .whereField("user_id", isEqualTo:userId)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: DBUser.self)
                if (user.userId == userId) {
                    return user
                }
            }
        } catch {
            print("searchUser by userId - Error getting documents: \(error)")
        }
        return nil
    }

    // Recherche, avec le contact_id, du contact dans la nase "Users" 
    func searchUser(contactId: String) async throws -> DBUser? {
        do {
            let querySnapshot = try await DBUserCollection
                .whereField("user_id", isEqualTo:contactId)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: DBUser.self)
                if (user.userId == contactId) {
                    return user
                }
            }
        } catch {
            print("searchUser by userId - Error getting documents: \(error)")
        }
        return nil
        
    }

    
    
    // Création de l'avatar dans "Storage" et maj de l'avatar dans "Users"
    func updateAvatar(userId: String, mimage: UIImage) async throws {
        let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: userId) // maj storage
        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        try await UsersManager.shared.updateImagePath(userId: userId, path: lurl.absoluteString) // maj "users"
    }
    
    // SettingsView TODO ajouter le champ nom dans "users"
    //    func saveNom(user_id: String, nom: String) async throws {
    //        do {
    //            let docRef = userDocument(userId: user_id)
    //            try await docRef.setData([ "nom":nom ] , merge: true)
    //        } catch {
    //            print("searchContact - Error getting documents: \(error)")
    //        }
    //    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
        // print("resetPAssword **********************************")
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print("**** signOut failed")
        }
    }
    
    // Création d'un token
    func newToken(userId: String, fcmToken: String) async throws {
        
        let rep: Bool = try await searchToken(userId: userId, fcmToken: fcmToken)
        
        if !rep {
            let document = UserTokensCollection(user_id: userId).document()
            let docId = document.documentID
            
            let data: [String:Any] = [
                "id" : docId,
                "user_id" : userId,
                "fcm_token" : fcmToken,
            ]
            do {
                try await document.setData(data, merge: false)
            } catch {
                print("newFcmToken: \(error)")
            }
        }
    }
    
    // Ext-ce que le token existe pour ce user
    func searchToken(userId: String, fcmToken: String) async throws -> Bool {
        do {
            let querySnapshot = try await tokensCollection
                .whereField("user_id", isEqualTo: userId)
                .whereField("fcm_token", isEqualTo: fcmToken)
                .getDocuments()
            
            for _ in querySnapshot.documents {
                return true
            }
        } catch {
            print("searchToken - Error getting documents: \(error)")
        }
        return false

    }
// A Adapter si on doit mettre à jour le token au lieu de le creer
//    func updateFCMToken(userId: String, fcmtoken: String) async throws {
//        let data: [String:Any] = [
//            FcmTokens.CodingKeys.fcmToken.rawValue : fcmtoken,
//        ]
//        try await userDocument(user_id: userId).updateData(data)
//    }

}
