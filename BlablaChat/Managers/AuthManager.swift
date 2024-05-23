//
//  AuthManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import Foundation
import FirebaseAuth

struct AuthUser {
    let uid: String
    let email: String?
    
    init(user: User) { // User est un type FireAuth
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthManager {
    
    static let shared = AuthManager()
    
    init() {}
    
    // Nouveau compte
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthUser {
        let AuthDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUser(user: AuthDataResult.user)
    }

    func getAuthenticatedUser() throws -> AuthUser{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthUser(user: user)
    }
    
    // Déjà un compte
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthUser {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(user: authDataResult.user)
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print("**** signOut failed")
        }
    }
}
