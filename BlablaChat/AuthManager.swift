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
    
    init(user: User) { // User est un type FireBase
        self.uid = user.uid
        self.email = user.email
    }
}

final class AuthManager {
    
    static let shared = AuthManager()
    
    init() {}

    func getCurrentUser() throws -> AuthUser{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthUser(user: user)
    }
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                return
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
        }
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
    
}
