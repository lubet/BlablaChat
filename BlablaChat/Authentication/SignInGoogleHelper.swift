//
//  SignInGoogleHelper.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 28/10/2024.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoggleSignInResultModel {
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper {
    
    @MainActor
    func signIn() async throws -> GoggleSignInResultModel {
        
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoggleSignInResultModel.init(idToken: idToken, accessToken: accessToken)
        
        return tokens
    }
}
