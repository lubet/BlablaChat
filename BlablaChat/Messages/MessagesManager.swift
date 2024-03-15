//
//  MessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 12/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

struct MessagesRoom: Identifiable, Codable {
    let room_id: String
    let room_name: String
    let from_id: String
    let to_id: String
    let message_text: String
    let date_send: Timestamp
    
    var id: String {
       room_id
    }
    
    init(
        room_id: String,
        room_name: String,
        from_id: String,
        to_id: String,
        message_text: String,
        date_send: Timestamp
    ) {
        self.room_id = room_id
        self.room_name = room_name
        self.from_id = from_id
        self.to_id = to_id
        self.message_text = message_text
        self.date_send = Timestamp()
    }
}


final class MessagesManager {
    
    static let shared = MessagesManager()
    
    init() { }
    
    // -----------------------------------------------------------------
    private let roomCollection = db.collection("rooms")
    
    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }
    
    // Tous les messages d'un room
    private func messageCollection(room_id: String) -> CollectionReference {
        roomDocument(room_id: room_id).collection("messages")
    }
    
    // Un message dans un room
    private func messageDocument(room_id: String, message_id: String) -> DocumentReference {
        messageCollection(room_id: room_id).document(message_id)
    }
    
    
    func getAllRooms() async throws -> [Room] {
        var rooms = [Room]()
        do {
            let querySnapshot = try await roomCollection.getDocuments()
            for document in querySnapshot.documents {
                let room = try document.data(as: Room.self)
                rooms.append(room)
            }
        } catch {
            print("getAllRooms - Error getting documents: \(error.localizedDescription)")
        }
        return rooms
    }
    
//    func getMessagesRoom(room_id) -> [MessagesRoom] {
//
//
//
//
//    }
    
    
    // Mes derniers messages in or out
    func getLastMessages(user_id: String) async throws -> [Message] {
        var myMessages = [Message]()
        
        let querySnapshot = try? await db.collectionGroup("messages").whereFilter(Filter.orFilter([
            Filter.whereField("from_id", isEqualTo: user_id),
            Filter.whereField("to_id", isEqualTo: user_id)
        ]))
            .getDocuments()
        
        if let snap = querySnapshot {
            for doc in snap.documents {
                let msg = try doc.data(as: Message.self)
                myMessages.append(msg)
            }
        }
        return myMessages
    }
    // -------------------------------------------------------------------
}
