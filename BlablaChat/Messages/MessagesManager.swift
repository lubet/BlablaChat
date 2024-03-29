//
//  MessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

struct MessageBubble: Identifiable{
    let id: String
    let message_text: String
    let message_date: String
    
    init(id: String, message_text: String, message_date: String) {
        self.id = id
        self.message_text = message_text
        self.message_date = message_date
    }
}


final class MessagesManager {
    
    static let shared = MessagesManager()
    
    init() { }

    // Tous les messages d'un room en ordre décroissant
    func getRoomMessages(room_id: String) async throws -> [MessageBubble] {
        // Collecter tous messages avec le room_id
        var messagesBubble = [MessageBubble]()
        
        do {
            let querySnapshot = try? await db.collectionGroup("messages")
                .whereField("room_id", isEqualTo: room_id)
                .order(by: "date_send")
                .getDocuments()
            
            if let snap = querySnapshot {
                for doc in snap.documents {
                    let msg = try doc.data(as: Message.self)
                    let oneBubble = MessageBubble(id: UUID().uuidString, message_text: msg.message_text, message_date: timeStampToString(dateMessage: msg.date_send))
                    messagesBubble.append(oneBubble)
                    print("\(msg.id)")
                }
            }
        } catch {
            print("getMessages - Error getting documents: \(error.localizedDescription)")
        }
        print("getRoomMessages: \(messagesBubble)")
        return messagesBubble
    }
}
