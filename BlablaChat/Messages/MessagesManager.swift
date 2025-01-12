//
//  MessagesManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

private let dbFS = Firestore.firestore()

final class MessagesManager {
    
    static let shared = UsersManager()
    init() { }
    
    private let MessagesCollection = dbFS.collection("Messages")
    
    private func messageDocument(user_id:String) -> DocumentReference {
        return MessagesCollection.document(user_id)
    }
    
    // Get mes Messages
    func getMessages(userId: String) async throws -> [Messages] {
        let snapshot = try await Firestore.firestore().collection("Messages").getDocuments()
        
        var messages = [Messages]()
        
        for document in snapshot.documents {
            let msg = try document.data(as: Messages.self)
            if msg.from != userId {
                messages.append(msg)
            }
        }
        return messages
    }

}

