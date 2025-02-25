//
//  AuthenticationView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/04/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

import AuthenticationServices

// Globales
// var user: DBUser = DBUser(id: "", email: "", dateCreated: Timestamp(), avatarLink: "", userId: "")

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    @Published var didSignInWithApple: Bool = false
    let signInAppleHelper = SignInAppleHelper()
    
    // Nouveau user Apple
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let _ = try await AuthManager.shared.signInWithApple(tokens: signInAppleResult)
                        
                        // -----------------------------------------------------------------------
                        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else {
                            print("**** Erreur signUpApple() - AuthUser = nil")
                            return
                        }
                        guard let email = authUser.email else {
                            print("**** Erreur: SignUpApple() - Pas d'email")
                            return
                        }
                        
                        let dbuser = try await UsersManager.shared.searchUser(email: email)
       
                        if dbuser == nil {
                            let user = DBUser(auth: authUser) // uid, email, user_id, date
                            try await UsersManager.shared.createDbUser(user: user) // sans l'image
                            let image = UIImage.init(systemName: "person.circle.fill")!
                            try await UsersManager.shared.updateAvatar(userId: user.userId, mimage: image) // Storage + maj de l'avatarLink dans le "user" crée
                        } else {
                            // Existe déjà - maj de l'uid
                            guard let userId = dbuser?.userId else { print("**** signUp - userId = nil"); return }
                            try await UsersManager.shared.updateId(userId: userId, Id: authUser.uid)
                        }
                        
                        // Je sauve le user sur le disque
                        if let encodedData = try? JSONEncoder().encode(dbuser) {
                            UserDefaults.standard.set(encodedData, forKey: "saveuser")
                        }
                        // --------------------------------------------------------------------
                        
                        self.didSignInWithApple = true
                        
                    } catch let error {
                        let erreur = error.localizedDescription
                        print("Erreur Sign in with Apple...\(erreur)" )
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func signUpApple() async throws {
        
        // Get firebase connection infos
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else {
            print("**** Erreur signUpApple() - AuthUser = nil")
            return
        }
        guard let email = authUser.email else {
            print("**** Erreur: SignUpApple() - Pas d'email")
            return
        }
        // Chercher dans "users" pour voir si il n'existe pas (cas d'un nouveau contact)
        var dbuser = try await UsersManager.shared.searchUser(email: email)

        if dbuser == nil {
            let user = DBUser(auth: authUser) // uid, email, user_id, date
            try await UsersManager.shared.createDbUser(user: user) // sans l'image
        } else {
            // Existe déjà - maj de l'uid
            guard let userId = dbuser?.userId else { print("**** signUp - userId = nil"); return }
            try await UsersManager.shared.updateId(userId: userId, Id: authUser.uid)
        }

        // lire le user venant d'être créer ou existant avec l'email (pour récupérer avatarLink maj plus haut)
        dbuser = try await UsersManager.shared.searchUser(email: email)

        // Je sauve sur le disque le user de la base
        if let encodedData = try? JSONEncoder().encode(dbuser) {
            UserDefaults.standard.set(encodedData, forKey: "saveuser")
        }
        
        // try await TokensManager.shared.addToken(auth_id: auth_id, FCMtoken: G.FCMtoken)

    }
}

struct AuthenticationView: View {

    @StateObject private var vm = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.theme.background
            VStack {
                
                // -------------- SignIn with Apple
                Button(action: {
                    Task {
                        do {
                            try await vm.signInApple() // ne renvoie rien, si on est connecté est gérer par le "onChange" plus bas.
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
                
                .onChange(of: vm.didSignInWithApple) { oldValue, newValue in
                    if newValue == true {
                        // Je suis connecté pour la première fois
                        // Je prépare mon profile et le sauve
                        Task {
                            try await vm.signUpApple()
                        }
                        showSignInView = false
                    }
                }
                
                // ------------- Sign In/Up with email/password
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
                .padding(.bottom,40)
                
            }
            .padding(.horizontal, 20)
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
