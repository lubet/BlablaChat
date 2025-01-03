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
    
    private let DBUserCollection = dbFS.collection("users")
    
    private func userDocument(user_id:String) -> DocumentReference {
        return DBUserCollection.document(user_id)
    }
    
    func createDbUser() async throws {
        try userDocument(user_id: user.id).setData(from: user, merge: false)
    }
    
    func updateImagePath(userId: String, path: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.avatarLink.rawValue : path,
        ]
        try await userDocument(user_id: userId).updateData(data)
    }
    
    // Get all users sauf moi
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
    
    // --------------------------------------------------------------
    
    // ---------------------------------------------------
    
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
    func createUser(email:String) async throws -> String {
        let userRef = DBUserCollection.document()
        let user_id = userRef.documentID
        
        let data: [String:Any] = [
            "user_id" : user_id,
            "email": email,
            "date_created" : Timestamp()
        ]
        try await userRef.setData(data, merge: false)
        
        return user_id
    }
    
    
    // Recherhe de l'email dans "users"
    func searchEmail(user_id: String) async throws -> (String, String) {
        do {
            let querySnapshot = try await DBUserCollection
                .whereField("user_id", isEqualTo: user_id)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: DBUser.self)
                if (user.userId == user_id) {
                    return (user.email ?? "", user.avatarLink ?? "")
                }
            }
        } catch {
            print("searchContact - Error getting documents: \(error)")
        }
        return ("","")
        
    }
    
    // Création de l'avatar dans "Storage" et maj de l'avatar dans "Users"
    func updateAvatar(mimage: UIImage) async throws {
        let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: user.userId)
        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        try await UsersManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore
        // print("updateAvatar \(lurl)")
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
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print("**** signOut failed")
        }
    }
}
