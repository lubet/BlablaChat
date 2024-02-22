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

    
    func lastMessages() async throws {
        
        do {
            let querySnapshot = try await messageCollection.getDocuments()
            
            var msg = [Message]()
            
            for document in querySnapshot.documents {
                let mes = try document.data(as: Message.self)
                msg.append(mes)
                print("\(msg)")
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
}
