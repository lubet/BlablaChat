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
    
    @discardableResult
    func createUser(email:String, password:String) async throws -> AuthUser {
        let AuthDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUser(user: AuthDataResult.user)
    }

    func getAuthenticatedUser() throws -> AuthUser{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthUser(user: user)
    }
    
    func signInUser(email:String, password:String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                return
            }
            print("Successfully loginuser: \(result?.user.uid ?? "")")
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print("**** signOut failed")
        }
    }
}
