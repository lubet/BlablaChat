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
    
    private func userDocument(auth_id: String) -> DocumentReference {
        return userCollection.document(auth_id)
    }
    
    // Membres
    private let memberCollection = db.collection("members")
    
    private func memberDocument(auth_id: String) -> DocumentReference {
        return memberCollection.document(auth_id)
    }

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
    func getMyRoomsId(auth_id: String) async throws -> [Member] {
        var members = [Member]()
        do {
            let querySnapshot = try await memberCollection.whereFilter(Filter.orFilter([
                    Filter.whereField("from_id", isEqualTo: auth_id),
                    Filter.whereField("to_id", isEqualTo: auth_id)
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
    
    // // Rechercher l'avatar_link dans "users" avec le auth_id
    func getAvatarLink(auth_id: String) async throws -> String {
        
        var avatarLink: String = ""
        
        do {
            let querySnapshot = try await userCollection.whereFilter(Filter.orFilter([
                    Filter.whereField("auth_id", isEqualTo: auth_id)
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
    
    // Recherche de l'email dans "users" avec le auth_id
    func getEmail(auth_id: String) async throws -> String {
        
        var email: String = ""
        
        do {
            let querySnapshot = try await userCollection.whereFilter(Filter.orFilter([
                    Filter.whereField("auth_id", isEqualTo: auth_id)
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
     
    func getAllRooms() async throws -> [Room] {
        
        var rooms = [Room]()
        
        do {
            let querySnapshot = try await roomCollection
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
    
}
