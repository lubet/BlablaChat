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
    
    // Récupérer de member les room_id pour lequelles je suis membre
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
            print("getMyRooms - Error getting documents from members: \(error.localizedDescription)")
        }
        return members
    }
    
    func getLastMessages(room_id: String) {
        
    }
}
