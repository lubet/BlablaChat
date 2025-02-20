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
    
    // Apple
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let _ = try await AuthManager.shared.signInWithApple(tokens: signInAppleResult)
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
    
    func signUpApple() async throws {
        
        // authUser
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else {
            print("**** Erreur signUpApple() - AuthUser = nil")
            return
        }
        
        // email
        guard let email = AuthUser.email else {
            print("**** Erreur: SignUpApple() - Pas d'email")
            return
        }
        
        // Création d'un objet dbUser sans l'image mais le user_id est par défaut
        var dbuser = DBUser(id: AuthUser.uid, email: AuthUser.email)
   
        // Est ce que le user existe déjà dans "Users"
        let userUsers = try await UsersManager.shared.searchUser(email: email)
        
        // Si le user existe déjà dans la base "Users" je l'utilise
        if userUsers != nil {
            dbuser = userUsers!
        } else {
            // le user n'existe pas dans "Users", je le crée.
            try await UsersManager.shared.createDbUser(user: dbuser) // sans l'image mais pour générer le user_id

            // Avatar par défaut pour le signUp Apple
            let image = UIImage.init(systemName: "person.circle.fill")!
            
            // Création de l'avatar dans "Storage", maj de l'avatarLink dans "users",
            let avatarLink = try await UsersManager.shared.updateAvatar(mimage: image) // le user_id est chargé dans l'updateAvatar()

            dbuser = DBUser(id: AuthUser.uid, email: AuthUser.email, avatarLink: avatarLink)
        }
        // UserDefaults - Save user
        print("dbuser:\(dbuser)")
        if let encodedData = try? JSONEncoder().encode(dbuser) {
            UserDefaults.standard.set(encodedData, forKey: "saveuser")
        }
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
