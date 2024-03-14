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
           
    // Collection messages - sous collection de rooms
    private func messageCollection(room_id: String) -> CollectionReference {
        roomDocument(room_id: room_id).collection("messages")
    }
    
    // Document message
    private func messageDocument(room_id: String, message_id: String) -> DocumentReference {
        messageCollection(room_id: room_id).document(message_id)
    }

    
    // LastMessages
    func getLastMessages(user_id: String) async throws -> [MessageItem] {
        
        print("user_id:\(user_id)")
        
        db.collectionGroup("messages").whereField("from_id", isEqualTo: user_id).getDocuments { (snapshot,  error) in
                if let e = error {
                    //this is printing the error if there is one getting the documents
                    print("There was an error getting the documents \(e)")
                } else {
                    if let dorms = snapshot?.documents { //accesses all the documents in the collection
                        for doc in dorms {
                            let data = doc.data() //Gets all the information in the document
                            //Here you would use an if let to create variables from the information in the data
                            //For example
                            if let dormRoomNumber = data["message_text"] //make sure the the data type here mathces the data type in your firestore database
                            {
                                let someVariable = dormRoomNumber
                                print("message: \(someVariable)")
                            }
                        }
                    }

                }
            }
        
        
        
        
        // fetch de tous les rooms où j'apparais dans le from ou dans le to
        var myMessages = [MessageItem]()
        
//            Firestore.firestore().collectionGroup("messages")
//                .whereField("from_id", isEqualTo: user_id)
//                .getDocuments { (snapshot, error) in
//                    print(snapshot?.documents.count ?? 0)
//                }
        
        // Rooms
//        let roomsSnap = try await roomCollection
//            .order(by: "room_id")
//            .getDocuments()
//
//        print("number: \(roomsSnap.documents.count)")
//
//        for document in roomsSnap.documents {
//            let room = try document.data(as: Room.self)
//            let roomId = room.room_id
//            let roomName = room.room_name
//
//            let messagesSnap = try await messageCollection(room_id: roomId)
//                .whereFilter(Filter.orFilter([
//                    Filter.whereField("from_id", isEqualTo: user_id),
//                    Filter.whereField("to_id", isEqualTo: user_id)
//                ])
//                )
//                .order(by: "date_send")
//                .limit(to: 1)
//                .getDocuments()
//
//            for oneMessage in messagesSnap.documents {
//                let msg = try oneMessage.data(as: MessageItem.self)
//                myMessages.append(msg)
//            }
//        }
//        print("getLastMessages - myRooms: \(myMessages)")
        
        return myMessages
    }
    
}
