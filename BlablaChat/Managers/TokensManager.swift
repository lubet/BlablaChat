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
    
    private func tokenDocument(auth_id: String) -> DocumentReference {
        return tokensCollection.document(auth_id)
    }

    // Ajouter le FCMtoken à "tokens"
    func addToken(auth_id: String, FCMtoken: String) async throws {
        do {
            let docRef = tokenDocument(auth_id: auth_id)
            
            let data: [String:Any] = [
                "auth_id" : auth_id,
                "token" : FCMtoken,
                "time_stamp" : Timestamp(),
                "nom": "",
            ]
            try await docRef.setData(data, merge: false)
        } catch {
            print("addToken Pas de document pour ce auth_id: \(error)")
        }
    }
    
    // TODO Display name pour les notifications à taper dans SettingsView
    func saveNom(auth_id: String, nom: String) async throws {
        do {
            let docRef = tokenDocument(auth_id: auth_id)
            let data: [String:Any] = ["nom": nom]
            try await docRef.setData(data, merge: true)
        } catch {
            print("saveNom Pas de document pour ce auth_id: \(error)")
        }
    }
}
