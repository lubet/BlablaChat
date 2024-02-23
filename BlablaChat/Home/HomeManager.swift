//
//  HomeManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/02/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let db = Firestore.firestore()


final class HomeManager {
    
    static let shared = HomeManager()
    
    init() { }
    
    private let DBUserCollection = db.collection("users")
    
    private func userDocument(email:String) -> DocumentReference {
        return DBUserCollection.document(email)
    }
    
    private let groupMemberCollection = db.collection("group_member")
    
    private let conversationCollection = db.collection("conversation")
    
    private let messageCollection = db.collection("message")
    
    //-----------------------------------------------------------------

    
    func lastMessages(from_to: String) async throws {
        
        var messages = [Message]()

        // Messages envoyés par moi
        let querySnapShot = try await messageCollection
            .whereField("from_id", isEqualTo: from_to)
            .order(by: "date_send", descending: true)
            .getDocuments()
        for document in querySnapShot.documents {
            let mes = try document.data(as: Message.self)
            messages.append(mes)
            print("\(messages)")
        }
        
        // Recher dans membre tous les conversations_id égaux aus miens -> les contact_id concernés
    }
}
