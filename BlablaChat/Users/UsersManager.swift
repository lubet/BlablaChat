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
    
    // Maj du token FCM (Firebase Cloud Messaging - Notificatons) qui identifie le device
    //    func updateFCMtoken(userId: String, FCMtoken: String) async throws {
    //        let data: [String:Any] = [
    //            DBUser.CodingKeys.FCMtoken.rawValue : FCMtoken,
    //        ]
    //        try await userDocument(userId: userId).updateData(data)
    //    }
    
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
    
    // --------------------------------------------------------------
    
    // ---------------------------------------------------
    private let DBUserCollection = dbFS.collection("users")
    
    private func userDocument(email:String) -> DocumentReference {
        return DBUserCollection.document(email)
    }
    
    private func userDocument(user_id:String) -> DocumentReference {
        return DBUserCollection.document(user_id)
    }
    
    // ---------------------------------------------------------------
    private let MemberCollection = dbFS.collection("members")
    
    private func memberDocument(user_id: String) -> DocumentReference {
        return MemberCollection.document(user_id)
    }
    
    // -----------------------------------------------------------------
    private let roomCollection = dbFS.collection("rooms")
    
    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }
    
    // ---------------------------------------------------------------
    private let messageCollection = dbFS.collection("messages")
    
    private func messageDocument(user_id: String) -> DocumentReference {
        return messageCollection.document(user_id)
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
                return roomId
            }
        } catch {
            print("searchDuo - Error getting documents from members: \(error)")
        }
        print("searchDuo - La paire n'existe pas dans members")
        return ""
    }
    
    // Recherche de l'id de mon interlocuteur dans "members"
    func searchDuo(from_id: String, room_id: String) async throws -> String {
        
        do {
            let memberSnapshot = try await MemberCollection.whereFilter(Filter.orFilter([
                Filter.andFilter([
                    Filter.whereField("from_id", isEqualTo: from_id),
                    Filter.whereField("room_id", isEqualTo: room_id)
                ]),
                Filter.andFilter([
                    Filter.whereField("to_id", isEqualTo: from_id),
                    Filter.whereField("room_id", isEqualTo: room_id)
                ])
            ])
            ).getDocuments()
            
            for duo in memberSnapshot.documents {
                let duo = try duo.data(as: Member.self)
                let roomId = duo.to_id
                return roomId
            }
        } catch {
            print("searchDuo - Error getting documents from members: \(error)")
        }
        print("searchDuo - La paire n'existe pas dans members")
        return ""
    }
    
    
    // New Room pour les contacts (avatar dans "rooms")
    func createRoom(avatar_link: String) async throws -> String {
        let roomRef = roomCollection.document()
        let room_id = roomRef.documentID
        
        let data: [String:Any] = [
            "room_id" : room_id,
            "date_created" : Timestamp(),
            "last_message" : "",
            "avatar_link" : avatar_link
        ]
        try await roomRef.setData(data, merge: false)
        
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
    
    func createMembers(user_id:String, room_id:String) async throws {
        let memberRef = MemberCollection.document()
        let member_id = memberRef.documentID
        
        let data: [String:Any] = [
            "id": member_id,
            "user_id": user_id,
            "room_id": room_id
        ]
        try await memberRef.setData(data, merge: false)
    }
    
    // retourne vrai si le tryptique combiné existe dans "members"
    func dejaMembre(room_id: String, user_id: String, contact_id: String) async throws -> Bool {
        
        do {
            let memberSnapshot = try await MemberCollection.whereFilter(Filter.orFilter([
                Filter.andFilter([
                    Filter.whereField("from_id", isEqualTo: user_id),
                    Filter.whereField("to_id", isEqualTo: contact_id),
                    Filter.whereField("room_id", isEqualTo: room_id),
                ]),
                Filter.andFilter([
                    Filter.whereField("from_id", isEqualTo: contact_id),
                    Filter.whereField("to_id", isEqualTo: user_id),
                    Filter.whereField("room_id", isEqualTo: room_id),
                ])
            ])
            ).getDocuments()
            
            for _ in memberSnapshot.documents {
                return true
            }
        } catch {
            print("searchDuo - Error getting documents from members: \(error)")
        }
        return false
    }
    
    
    // Création du message et maj du dernier message de Room avec le message
    func createMessage(from_id: String, message_text: String, room_id: String, image_link: String, to_id: String) async throws {
        let messageRef = messageCollection.document()
        let message_id = messageRef.documentID
        
        let dateMessage = Timestamp()
        
        var msg = message_text
        if msg == "" {
            msg = "Photo"
        }
        
        let data: [String:Any] = [
            "id": message_id,
            "from_id": from_id,
            "message_text": msg,
            "date_send": dateMessage,
            "room_id": room_id,
            "image_link": image_link,
            "to_id": to_id
        ]
        try await messageRef.setData(data, merge: false)
        
        // Ajout/replace du dernier message dans "rooms"
        let roomRef = roomDocument(room_id: room_id)
        
        let dataRoom: [String:Any] = [
            "last_message": msg,
            "date_message": dateMessage,
            "user_id": from_id,
            "image_link": image_link,
            "to_id": to_id
        ]
        
        try await roomRef.setData(dataRoom, merge: true)
    }
    
    // Recherche du room_id dans "members" avec le user_id
    func searchRoomId(user_id: String) async throws -> String {
        do {
            let memberSnapshot = try await MemberCollection
                .whereField("user_id", isEqualTo: user_id)
                .getDocuments()
            
            for duo in memberSnapshot.documents {
                let duo = try duo.data(as: Member.self)
                let roomId = duo.room_id
                return roomId
            }
        } catch {
            print("searchRoomId - Error getting documents from members: \(error)")
        }
        print("searchDuo - La paire n'existe pas dans members")
        return ""
        
        
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
    
    // Maj de l'avatar dans "user" à partir de SettingsView
    func updateAvatar(userId: String, mimage: UIImage) async throws {
        let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: userId)
        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        try await UsersManager.shared.updateImagePath(userId: userId, path: lurl.absoluteString) // maj Firestore
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
    }
}
