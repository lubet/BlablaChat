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
    
    @AppStorage("currentUserId") var currentUserId: String?
    
    let signInAppleHelper = SignInAppleHelper()
    
    // Nouveau user Apple
    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let _ = try await AuthManager.shared.signInWithApple(tokens: signInAppleResult)
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
    
    // Traitement aprés le SignUp Apple
    func appleAfterSignUp() async throws {
        
        // Récupérer l'auth connecté
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { print("authUser nil; return "); return }
        
        // email de l'auth connecté
        guard let email = authUser.email else { print("appleAfterSignUp() email nil"); return }
        
        // Est-ce que l'auth connecté existe dans la base User ?
        let dbuser = try await UsersManager.shared.searchUser(email: email)

        if dbuser == nil {
            
            let nomprenom = LogInManager.shared.getContactName(email: email)
            let nom = nomprenom.nom
            let prenom = nomprenom.prenom
            
            // Création du user à partir de l'auth que l'on complète
            let user = DBUser(auth: authUser, nom: nom, prenom: prenom) // auth.uid, email, userId
 
            try await UsersManager.shared.createDbUser(user: user) // sans l'image

            let image = UIImage.init(systemName: "person.circle.fill")!

            try await UsersManager.shared.updateAvatar(userId: user.userId, mimage: image) // Storage + maj de l'avatarLink dans le "user" crée
            self.currentUserId = user.userId // global à l'appli

        } else {
            // Existe déjà - maj de l'id du user + save du userId
            guard let userId = dbuser?.userId else { print("**** signUp - userId = nil"); return }
            try await UsersManager.shared.updateId(userId: userId, Id: authUser.uid)
            self.currentUserId = userId // global à l'appli
        }
        
        // Le userId de DBUser est l'identifiant unique pour toute l'appli
        guard let currentUID = self.currentUserId else { print("SignUp-Pas de userId"); return }
        
        // Recherche du token FCM, servira pour les notifications
        let tokenFCM = try await UsersManager.shared.searchTokenFCM(userId: currentUID)
        
        if tokenFCM == nil {
            try await UsersManager.shared.addTokenFCM(userId: currentUID, tokenFCM: FCMtoken.FCMtoken)
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
                        // Traitement après le login Apple
                        Task {
                            try await vm.appleAfterSignUp()
                            showSignInView = false // -> retour à la RootView pour entrée dans l'appli
                        }
                    }
                }
                
                // ------------- Sign In/Up with email/password
                NavigationLink(destination: {
                    LoginEmailView(showSignInView: $showSignInView)
                }, label: {
                    Text("S'authentifier avec l'email")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.buttoncolor)
                        .foregroundStyle(Color.theme.buttontext)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                })
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
