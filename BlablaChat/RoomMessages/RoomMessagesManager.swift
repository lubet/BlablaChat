//
//  RoomMessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 27/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

final class RoomMessagesManager {
    
    static let shared = RoomMessagesManager()
    
    init() { }

    // -----------------------------------------------------------------
    private let roomCollection = db.collection("rooms")
    
    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }
    
    // Collection messages - sous collection de rooms
    private func messageCollection(room_id: String) -> CollectionReference {
        roomDocument(room_id: room_id).collection("messages")
    }

    // Tous les messages d'un room en ordre décroissant
    func getRoomMessages(room_id: String) async throws -> [Message] {
        // Collecter tous messages avec le room_id
        var roomMessages = [Message]()
        
        do {
            let querySnapshot = try? await db.collectionGroup("messages")
                .whereField("room_id", isEqualTo: room_id)
                .order(by: "date_send", descending: true)
                .getDocuments()
            
            if let snap = querySnapshot {
                for doc in snap.documents {
                    let msg = try doc.data(as: Message.self)
                    roomMessages.append(msg)
                    print("\(msg.id)")
                }
            }
        } catch {
            print("getMessages - Error getting documents: \(error.localizedDescription)")
        }
        return roomMessages
    }
}
