//
//  MessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//
// Tous les messages d'un room (conversation avec quelqu'un)
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()

struct MessageBubble: Identifiable{
    let id: String
    let message_text: String
    let message_date: String
    let received: Bool
    let imageLink: String
    
    init(id: String, message_text: String, message_date: String, received: Bool, imageLink: String) {
        self.id = id
        self.message_text = message_text
        self.message_date = message_date
        self.received = received
        self.imageLink = imageLink
    }
}

final class MessagesManager {
    
    static let shared = MessagesManager()
    
    init() { }
    
    // Membres
    private let memberCollection = db.collection("members")
    
    private let roomCollection = db.collection("rooms")

    // Tous les messages d'un room en ordre croissant pour affichage "bubble"
    func getRoomMessages(room_id: String, user_id: String) async throws -> [MessageBubble] {
        var messagesBubble = [MessageBubble]()
        var received: Bool = false
        
        do {
            let querySnapshot = try? await db.collectionGroup("messages")
                .whereField("room_id", isEqualTo: room_id)
                .order(by: "date_send")
                .getDocuments()
            
            if let snap = querySnapshot {
                for doc in snap.documents {
                    let msg = try doc.data(as: Message.self)
                    if (msg.from_id == user_id) {
                        received.toggle() // received = true
                    } else {
                        received.toggle() // received = false
                    }
                    let oneBubble = MessageBubble(id: UUID().uuidString, message_text: msg.message_text, message_date: timeStampToString(dateMessage: msg.date_send), received: received, imageLink: msg.image_link ?? "")
                    messagesBubble.append(oneBubble)
                }
            }
        } catch {
            print("getMessages - Error getting documents: \(error)")
        }
        return messagesBubble
    }
        
    // Recherche du user_id dans membre
    func getUserId(user_id: String) async throws -> String? {

        var to_id: String?
        
        print("getUserId \(user_id)")
        
        do {
            let querySnapshot = try? await memberCollection
                .whereField("user_id", isEqualTo: user_id)
                // OU .whereField("to_id", isEqualTo: user_id)
                .getDocuments()
            
            let nbMembre = querySnapshot?.count
            
            if (nbMembre != 1) {
                print("getUserId - Erreur nbre membres différend de un: \(nbMembre ?? 0)")
            } else {
                if let snap = querySnapshot {
                    for doc in snap.documents {
                        let membre = try doc.data(as: Member.self)
                        to_id = membre.to_id
                    }
                }
            }
        } catch {
            print("getToId - Error getting documents: \(error)")
        }
        return to_id
    }
    
    // Recherche du room_id dans rooms avec l'email(room_name)
    func getRoomId(email: String) async throws -> String {
        
        let roomId: String = ""
        
        do {
            let querySnapShot = try? await roomCollection
                .whereField("room_name", isEqualTo: email)
                .getDocuments()
            if let snap = querySnapShot {
                for doc in snap.documents {
                    let room = try doc.data(as: Room.self)
                    if room.room_name == email {
                        return room.room_id
                    }
                }
            }
        } catch {
            print("getRoomId- Error getting documents: \(error)")
        }
        print("Ereur: getRoomId - pas de roomId")
        return roomId
    }
}
