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
    let dateCreated: Timestamp
    let from_id: String
    let to_id: String
    let message_text: String
    let date_send: Timestamp
    
    var id: String {
       room_id
    }

    enum CodingKeys: String, CodingKey {
        case room_id
        case room_name
        case dateCreated = "date_created"
        case from_id
        case to_id
        case message_text
        case date_send
    }
    
    init(
        room_id: String,
        room_name: String,
        dateCreated: Timestamp,
        from_id: String,
        to_id: String,
        message_text: String,
        date_send: Timestamp
    ) {
        self.room_id = room_id
        self.room_name = room_name
        self.dateCreated = dateCreated
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
    
    // Completer chaque message avec le nom et la date des rooms
    func majMessages(messages: [Message], rooms: [Room]) async throws -> [MessageItem] {
        var messageItems = [MessageItem]()
        
        // Pour chaque message aller avec le room_id rechercher le nom du room dans rooms
        // creer un enreg MesageItem avec les données du message et du room
        for msg in messages {
            var msg_room_id = msg.room_id
            for room in rooms {
                if room.room_id == msg_room_id {
                    // Créer un messageItem et l'ajuter à "messageItems"
                    continue
                }
            }
        }
        return messageItems
    }
    
    // Tout mes messages send or received
    func getMessages(user_id: String) async throws -> [Message] {
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
                print("\(msg.id)")
            }
        }
        return myMessages
    }
    // -------------------------------------------------------------------
}
