//
//  MessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//
// Messages "bubble" d'un room
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

struct MessageBubble: Identifiable{
    let id: String
    let message_text: String
    let message_date: String
    let send: Bool
    
    init(id: String, message_text: String, message_date: String, send: Bool) {
        self.id = id
        self.message_text = message_text
        self.message_date = message_date
        self.send = send
    }
}

final class MessagesManager {
    
    static let shared = MessagesManager()
    
    init() { }

    // Tous les messages d'un room en ordre croissant pour affichage "bubble"
    func getRoomMessages(room_id: String, user_id: String) async throws -> [MessageBubble] {
        var messagesBubble = [MessageBubble]()
        var send: Bool
        
        do {
            let querySnapshot = try? await db.collectionGroup("messages")
                .whereField("room_id", isEqualTo: room_id)
                .order(by: "date_send")
                .getDocuments()
            
            if let snap = querySnapshot {
                for doc in snap.documents {
                    let msg = try doc.data(as: Message.self)
                    if (msg.from_id == user_id) {
                        send = true
                    } else {
                        send = false
                    }
                    let oneBubble = MessageBubble(id: UUID().uuidString, message_text: msg.message_text, message_date: timeStampToString(dateMessage: msg.date_send), send: send)
                    messagesBubble.append(oneBubble)
                }
            }
        } catch {
            print("getMessages - Error getting documents: \(error.localizedDescription)")
        }
        return messagesBubble
    }
}
