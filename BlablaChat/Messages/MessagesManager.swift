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

struct MessageItem: Identifiable, Codable {
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
    
    // ---------------------------------------------------------------------
    
//    let query = db.collection("cities").whereFilter(Filter.orFilter([
//                    Filter.whereField("capital", isEqualTo: true),
//                    Filter.whereField("population", isGreaterThanOrEqualTo: 1000000);
//                ]))
      
    
    
    // LastMessages
    func getLastMessages(user_id: String) async throws -> [MessageItem] {
        
        let myMessages = [MessageItem]()
        
        db.collectionGroup("messages").whereFilter(Filter.orFilter([
            Filter.whereField("from_id", isEqualTo: user_id),
            Filter.whereField("to_id", isEqualTo: user_id)
            ]))
            .getDocuments() { (snapshot,  error) in
            if let e = error {
                print("There was an error getting the documents \(e)")
            } else {
                if let messages = snapshot?.documents {
                    for doc in messages {
                        let data = doc.data()
                        if let dormRoomNumber = data["id"]
                        {
                            let someVariable = dormRoomNumber
                            print("message: \(someVariable)")
                        }
                    }
                }
            }
        }
        return myMessages
    }
    
    // -------------------------------------------------------------------
}
