//
//  TokensManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 12/10/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


private let db = Firestore.firestore()

final class TokensManager {
    
    static let shared = TokensManager()
    init() { }

    
    private let tokensCollection = db.collection("tokens")
    
    private func tokenDocument(token_id: String) -> DocumentReference {
        return tokensCollection.document(token_id)
    }

    // Ajouter le token
    func addToken(user_id: String, token: String) async throws {
        
        do {
            let docRef = tokensCollection.document()
            let user_id = docRef.documentID
            
            let data: [String:Any] = [
                "user_id" : user_id,
                "token" : token,
                "time_stamp" : Timestamp(),
            ]
            try await docRef.setData(data, merge: false)
        } catch {
            print(error)
        }
    }
}
