//
//  AuthenticationView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/04/2024.
//

import SwiftUI
import AuthenticationServices

@MainActor
final class AuthenticationViewModel: ObservableObject {
 
    @Published var didSignInWithApple: Bool = false
    let signInAppleHelper = SignInAppleHelper()
    
    // Apple
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let authUser = try await AuthManager.shared.signInWithApple(tokens: signInAppleResult)
                        self.didSignInWithApple = true
                        
                        guard let email = authUser.email else {
                            print("L'email du user Apple est égal à nil")
                            return
                        }

                        let contact_id  = try await UsersManager.shared.searchContact(email: email)
                        
                        if contact_id == "" {
                            
                            let user = DBUser(auth: authUser) // Instanciation userId email
                            
                            try await UsersManager.shared.createDbUser(user: user) // Save in Firestore sans l'image
                            
                            let mimage: UIImage = UIImage.init(systemName: "person.fill")!
                            
                            try await UsersManager.shared.updateAvatar(userId: user.authId, mimage: mimage)
                            
//                            let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: user.userId)
//                            
//                            let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
//                            
//                            try await UsersManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore
                            
                            try await TokensManager.shared.addToken(auth_id: authUser.uid, FCMtoken: G.FCMtoken)
                            
                        }
                    } catch {
                        print("Erreur Sign in with Apple...")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func FCMtoken() async throws {
        // Maj du FCMtoken
        let authUser = try! AuthManager.shared.getAuthenticatedUser()
        let auth_id = authUser.uid

        try await TokensManager.shared.addToken(auth_id: auth_id, FCMtoken: G.FCMtoken)
    }
    
//    func signInAnonymous() async throws {
//        try await AuthManager.shared.signInAnonymous()
//    }

}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.theme.background // voir "extension Color"
                .ignoresSafeArea()
            VStack {
                // SignIn with Apple
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signInApple() // ne renvoie rien, si on est connecté est gérer par le "onChange" plus bas.
                        } catch {
                            print(error)
                        }
                    }
                }, label: {
                    if self.colorScheme == .light {
                        SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                            .allowsHitTesting(false)
                    } else if self.colorScheme == .dark {
                        SignInWithAppleButtonViewRepresentable(type: .default, style: .white)
                            .allowsHitTesting(false)
                    } else {
                        SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                            .allowsHitTesting(false)
                    }
                })
                .frame(height: 55)
                
                // J'ai gardé l'ancienne version car la nouvelle ne fonctionne pas
                .onChange(of: viewModel.didSignInWithApple) { newValue in
                    if newValue == true {
                        showSignInView = false
                    }
                }
                
                // Sign In/Up with email/password
                NavigationLink {
                    LoginEmailView(showSignInView: $showSignInView)
                } label: {
                    Text("S'authentifier avec l'email")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                }
                .padding(.top, 20)

            }
            .padding(.horizontal, 20)
            .navigationTitle("Entrée")
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
