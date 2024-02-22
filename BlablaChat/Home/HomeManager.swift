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

struct LastMessage: Identifiable {
    let id: String = UUID().uuidString
    let to_id: String
    let texte: String
    let date_message: Timestamp
}

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

    
    func lastMessages(user_id: String) {
        // Récupere mes messages
        let snapshot = try await Firestore.firestore().collection("message")
            .whereField("from_id", isEqualTo: user_id)
            .getDocuments()

        
        
        
        
        
        // Récupérer le dernier message de chaque destinataire de message
        
        // Récupérer le denier message de chaque contact avec un message
        //
        for each contact dans messages
                récuprer le dernier message de c contact
                

        
        
        
        
    }
    
    
}
