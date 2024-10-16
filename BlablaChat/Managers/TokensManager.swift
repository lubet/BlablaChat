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

    // Ajouter le FCMtoken à "tokens"
    func addToken(user_id: String, FCMtoken: String) async throws {
        do {
            let docRef = tokensCollection.document(user_id)
            
            let data: [String:Any] = [
                "user_id" : user_id,
                "token" : FCMtoken,
                "time_stamp" : Timestamp(),
                "nom": "",
            ]
            try await docRef.setData(data, merge: false)
        } catch {
            print("addToken Pas de document pour ce user_id: \(error)")
        }
    }
    
    // Sauvegarde du nom taper dans SettingsView dans "tokens"
    func saveNom(user_id: String, nom: String) async throws {
        do {
            let docRef = tokensCollection.document(user_id)
            let data: [String:Any] = ["nom": nom]
            try await docRef.setData(data, merge: true)
        } catch {
            print("saveNom Pas de document pour ce user_id: \(error)")
        }
    }
}
