//
//  AuthUserModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 17/12/2024.
//

import Foundation
import FirebaseAuth

// TODO anonymous
struct AuthUser {
    let uid: String
    let email: String?
    // let isAnonymous: Bool
    
    init(user: User) { // User est un type FireAuth
        self.uid = user.uid
        self.email = user.email
        //self.isAnonymous = user.isAnonymous
    }
}
