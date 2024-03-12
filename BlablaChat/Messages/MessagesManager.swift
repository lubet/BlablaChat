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
    
    private let messageCollection = db.collection("message")
    
    // LastMessages
    func getLastMessages(user_id: String) async throws -> [Message] {
        
        var myMessage = [Message]()
 
        do {
            let messagesSnap = try await messageCollection
                .whereFilter(Filter.orFilter([
                    Filter.whereField("from_id", isEqualTo: user_id),
                    Filter.whereField("to_id", isEqualTo: user_id)
                ])
                )
                .order(by:"room_id")
                .order(by: "date_send")
                .limit(to: 1)
                .getDocuments()
            
            for document in messagesSnap.documents {
                let message = try document.data(as: Message.self)
                myMessage.append(message)
            }
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
        }
        return myMessage
    }

    //
    
}
