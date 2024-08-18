//
//  LastMessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

final class LastMessagesManager {
    
    static let shared = LastMessagesManager()
    
    init() { }
    
    // Rooms
    private let roomCollection = db.collection("rooms")
    
    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }

    // Users
    private let userCollection = db.collection("users")
    
    private func userDocument(user_id: String) -> DocumentReference {
        return userCollection.document(user_id)
    }
    
    // Membres
    private let memberCollection = db.collection("members")
    
    private func memberDocument(user_id: String) -> DocumentReference {
        return memberCollection.document(user_id)
    }
    
    // Tous les rooms de l'auth triès par date
//    func getAllRooms(room_id: String) async throws -> [Room] {
//        var rooms = [Room]()
//        do {
//            let querySnapshot = try await roomCollection
//                .whereField("room_id", isEqualTo: room_id)
//                .order(by: "date_created")
//                .getDocuments()
//            for document in querySnapshot.documents {
//                let room = try document.data(as: Room.self)
//                rooms.append(room)
//            }
//        } catch {
//            print("getAllRooms - Error getting documents: \(error)")
//        }
//        return rooms
//    }
    
    // Tous mes rooms
    func getMyRooms(room_id: String) async throws -> [Room] {
        
        var rooms = [Room]()
        do {
            let querySnapshot = try await roomCollection
                .whereField("room_id", isEqualTo: room_id)
                .order(by: "date_created")
                .getDocuments()
            for document in querySnapshot.documents {
                let room = try document.data(as: Room.self)
                rooms.append(room)
            }
        } catch {
            print("getMyRooms - Error getting documents: \(error)")
        }
        return rooms
    }
    
    // Ensemble de tous les enregs de "members" où l'auth est présent soit dans from_id ou soit dans to_id
    func getMyRoomsId(user_id: String) async throws -> [Member] {
        var members = [Member]()
        do {
            let querySnapshot = try await memberCollection.whereFilter(Filter.orFilter([
                    Filter.whereField("from_id", isEqualTo: user_id),
                    Filter.whereField("to_id", isEqualTo: user_id)
                ]))
                .order(by: "date_created")
                .getDocuments()
            for document in querySnapshot.documents {
                let membre = try document.data(as: Member.self)
                members.append(membre)
            }
        } catch {
            print("getMyRoomsId - Error getting documents from members: \(error)")
        }
        return members
    }
    
    // // Rechercher l'avatar_link dans "users" avec le user_id
    func getAvatarLink(user_id: String) async throws -> String {
        
        var avatarLink: String = ""
        
        do {
            let querySnapshot = try await userCollection.whereFilter(Filter.orFilter([
                    Filter.whereField("user_id", isEqualTo: user_id)
                ]))
                .getDocuments()
            for document in querySnapshot.documents {
                let membre = try document.data(as: DBUser.self)
                avatarLink = membre.avatarLink ?? ""
            }
        } catch {
            print("getAvatarLink - Error getting documents from members: \(error)")
        }
        return avatarLink

    }
    
    // Recherche de l'avatar dans "users" avec l'mail
    func getAvatarLink(email: String) async throws -> String {
        
        var avatarLink: String = ""
        
        do {
            let querySnapshot = try await userCollection.whereFilter(Filter.orFilter([
                    Filter.whereField("email", isEqualTo: email)
                ]))
                .getDocuments()
            for document in querySnapshot.documents {
                let membre = try document.data(as: DBUser.self)
                avatarLink = membre.avatarLink ?? ""
            }
        } catch {
            print("getAvatarLink - Error getting documents from members: \(error)")
        }
        return avatarLink

    }

    // Chercher le user_id (lequel ?) dans "members" avec le room_id
//    func getUserId(room_id: String) async throws -> String {
//        
//        var user_id: String = ""
//        
//        do {
//            let querySnapshot = try await memberCollection.whereFilter(Filter.orFilter([
//                    Filter.whereField("room_id", isEqualTo: user_id)
//                ]))
//                .getDocuments()
//            for document in querySnapshot.documents {
//                let membre = try document.data(as: Member.self)
//                user_id = membre.user_id
//            }
//        } catch {
//            print("getUserId - Error getting documents from members: \(error)")
//        }
//        return user_id
//
//    }
    
    // Recherche de l'email dans "users" avec le user_id
    func getEmail(user_id: String) async throws -> String {
        
        var email: String = ""
        
        do {
            let querySnapshot = try await userCollection.whereFilter(Filter.orFilter([
                    Filter.whereField("user_id", isEqualTo: user_id)
                ]))
                .getDocuments()
            for document in querySnapshot.documents {
                let membre = try document.data(as: DBUser.self)
                email = membre.email ?? ""
            }
        } catch {
            print("getEmail- Error getting documents from members: \(error)")
        }
        return email

    }
    
    // Dans "members", retourne le "from_id" et le "to_id" d'un room_id
    func getFromId(room_id: String) async throws -> (String, String) {
        var from_id: String = ""
        var to_id: String = ""
        do {
            let querySnapshot = try await memberCollection
                .whereField("room_id", isEqualTo: room_id)
                .getDocuments()
            for document in querySnapshot.documents {
                let membre = try document.data(as: Member.self)
                from_id = membre.from_id
                to_id = membre.to_id
            }
        } catch {
            print("getMyRoomsId - Error getting documents from members: \(error)")
        }
        return (from_id, to_id)
    }
    
}
