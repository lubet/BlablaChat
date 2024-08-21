//
//  AuthenticationView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/04/2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices


struct GoggleSignInResultModel {
    let idToken: String
    let accessToken: String
}




@MainActor
final class AuthenticationViewModel: ObservableObject {
    
 
    @Published var didSignInWithApple: Bool = false
    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws {
        
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoggleSignInResultModel.init(idToken: idToken, accessToken: accessToken)

        // Recherche du user Google dans la base "users" avec son email
        do {
            let authUser = try await AuthManager.shared.signInWithGoogle(tokens: tokens) // Renvoi user: authDataResult.user
            guard let email = authUser.email else {
                print("L'email du user Google est égal à nil")
                return
            }
             let contact_id  = try await UsersManager.shared.searchContact(email: email)
             if contact_id == "" {
                let user = DBUser(auth: authUser) // Instanciation userId email
                try await UsersManager.shared.createDbUser(user: user) // Save in Firestore sans l'image
                 
                 let mimage: UIImage = UIImage.init(systemName: "person.fill")!
                 
                 let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: user.userId)

                 let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)

                 try await UsersManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore

             }
        } catch {
            print("Erreur Sign in with Google...")
        }
    }
    
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let authUser = try await AuthManager.shared.signInWithApple(tokens: signInAppleResult)

                        guard let email = authUser.email else {
                            print("L'email du user Apple est égal à nil")
                            return
                        }

                        let contact_id  = try await UsersManager.shared.searchContact(email: email)
                        
                        if contact_id == "" {
                            
                            let user = DBUser(auth: authUser) // Instanciation userId email
                            try await UsersManager.shared.createDbUser(user: user) // Save in Firestore sans l'image
                            
                            let mimage: UIImage = UIImage.init(systemName: "person.fill")!
                            
                            let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: user.userId)
                            
                            let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
                            
                            try await UsersManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore
                            
                        }
                        self.didSignInWithApple = true
                    } catch {
                        print("Erreur Sign in with Apple...")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            VStack {
                
                // Sign In/Up with email/password
                NavigationLink {
                    LoginEmailView(showSignInView: $showSignInView)
                } label: {
                    Text("S'authentifié avec l'email")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                }
                
                // SignIn with Goggle
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal))
                {
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding(.bottom, 10)
                
                // SignIn with Apple
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signInApple()
                            // showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }, label: {
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                        .allowsHitTesting(false)
                })
                .frame(height: 55)
                .onChange(of: viewModel.didSignInWithApple) { newValue in
                    if newValue == true {
                        showSignInView = false
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("S'authentifier:")
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
