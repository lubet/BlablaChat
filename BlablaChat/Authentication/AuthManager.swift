//
//  AuthManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
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

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthManager {
    
    static let shared = AuthManager()
    init() {}

    func getAuthenticatedUser() throws -> AuthUser {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthUser(user: user)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        return providers
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print("**** signOut failed")
        }
    }
    
}

// MARK: SIGN IN EMAIL

extension AuthManager {
    // Nouveau compte
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthUser {
        let AuthDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthUser(user: AuthDataResult.user)
    }
    
    // Déjà un compte
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthUser {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthUser(user: authDataResult.user)
    }
}

// MARK: SIGN IN SSO (Google, Apple)

extension AuthManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoggleSignInResultModel) async throws -> AuthUser {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }

    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthUser {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthUser {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthUser(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
        // print("resetPAssword **********************************")
    }
}

// TODO Providers linking on anonymous account
// MARK: PROVIDERS LINKS ON CURRENT USER ANONYME

// extension AuthManager {
    
//    @discardableResult
//    func signInAnonymous() async throws -> AuthUser {
//        let authDataResult = try await Auth.auth().signInAnonymously()
//        return AuthUser(user: authDataResult.user)
//    }
    
//    func linkEmail(email: String, password: String) async throws -> AuthUser {
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        return try await linkCredential(credential: credential)
//    }
//    
//    func linkGoogle(tokens: GoggleSignInResultModel) async throws -> AuthUser {
//        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
//        return try await linkCredential(credential: credential)
//    }
//
//    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthUser {
//        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokens.token, rawNonce: tokens.nonce)
//        return try await linkCredential(credential: credential)
//    }
//    
//    // Appler par les link ci-dessus - link du provider sur le user courant
//    private func linkCredential(credential: AuthCredential) async throws -> AuthUser {
//        guard let user = Auth.auth().currentUser else {
//            throw URLError(.badURL)
//        }
//        
//        let authDataResult = try await user.link(with: credential)
//        return AuthUser(user: authDataResult.user)
//
//    }

// }

