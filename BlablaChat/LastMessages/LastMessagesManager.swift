//
//  LastMessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// A mettre dans la View
struct LastModel: Identifiable, Codable {
    let id: String
    let room_id: String
    let room_name: String // nom du créateur du premier message
    let room_date: String
    let message_texte: String
    let message_date: String
    let message_from: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case room_id = "room_id"
        case room_name = "room_name"
        case room_date = "room_date"
        case message_texte = "messge_texte"
        case message_date = "message_date"
        case message_from = "message_from"
    }
}

private let db = Firestore.firestore()

final class LastMessagesManager {
    
    // -----------------------------------------------------------------
    private let roomCollection = db.collection("rooms")
    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }

    private let userCollection = db.collection("users")
    private func userDocument(user_id: String) -> DocumentReference {
        return userCollection.document(user_id)
    }
    
    // TODO - Récupérer les rooms où je suis présent
    // room_name = email du créateur du room
    // Avec les messages je pourrai récupérer les rooms qui correspondent à mes messages
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
            print("getAllRooms - Error getting documents: \(error.localizedDescription)")
        }
        return rooms
    }
}
