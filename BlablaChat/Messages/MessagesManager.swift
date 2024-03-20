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
    
    // Tous les rooms triés par date
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
        
    // Tout mes messages send or received triés par dates
    func getMessages(user_id: String) async throws -> [Message] {
        var myMessages = [Message]()
        
        let querySnapshot = try? await db.collectionGroup("messages").whereFilter(Filter.orFilter([
            Filter.whereField("from_id", isEqualTo: user_id),
            Filter.whereField("to_id", isEqualTo: user_id)
        ]))
            .order(by: "date_send")
            .getDocuments()
        
        if let snap = querySnapshot {
            for doc in snap.documents {
                let msg = try doc.data(as: Message.self)
                myMessages.append(msg)
                print("\(msg.id)")
            }
        }
        return myMessages
    }
    // -------------------------------------------------------------------
}
