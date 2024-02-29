//
//  HomeManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/02/2024.
//
// Liste du dernier message reçu ou envoyé par room
// --------------------------------------------------------

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

struct ChatItem: Identifiable, Codable {
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

final class HomeManager {
    
    static let shared = HomeManager()
    
    init() { }
    
    // -------------------------------------------------
    private let DBUserCollection = db.collection("users")
    
    private func userDocument(email:String) -> DocumentReference {
        return DBUserCollection.document(email)
    }
    
    // -------------------------------------------------
    private let groupMemberCollection = db.collection("group_member")
    
    // -------------------------------------------------
    private let roomCollection = db.collection("Room")

    private func roomDocument(room_id: String) -> DocumentReference {
        return roomCollection.document(room_id)
    }
    // -------------------------------------------------

    private let messageCollection = db.collection("message")

    
    //===============================================
    
    
    // Sous-collections de room
    func getMyMessages(user_id: String) async throws -> [Message]{
        
        var myMessage = [Message]()
        
        let messageSnap  = try await messageCollection
            .whereFilter(Filter.orFilter([
            Filter.whereField("from_id", isEqualTo: user_id),
            Filter.whereField("to_id", isEqualTo: user_id)
            ]))
            .getDocuments()

        print("** \(messageSnap.documents)")
        
        for document in messageSnap.documents {
            let message = try document.data(as: Message.self)
            myMessage.append(message)
        }
        print("return myMessage \(myMessage)")
        return myMessage
    }
    
    // Renvoie le nom de la room correspondant au message
    func getRoom(room_id: String) async throws -> [Room] {
        
        print("geRoom \(room_id)")
        
        var chatRooms = [Room]()
        
        do {
            let querySnapshot = try await roomCollection
                .whereField("room_id", isEqualTo: room_id)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let chat = try document.data(as: Room.self)
                chatRooms.append(chat)
            }
        } catch {
            print("Error \(error.localizedDescription)")
        }
            
        print("chatRooms: \(chatRooms)")
        
        return chatRooms
        
    }
 }
