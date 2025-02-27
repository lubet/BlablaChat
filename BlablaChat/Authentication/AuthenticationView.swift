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
        print("**** signInApple()")
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        let _ = try await AuthManager.shared.signInWithApple(tokens: signInAppleResult)

                        // -----
                        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else {
                            print("**** Erreur signUpApple() - AuthUser = nil")
                            return
                        }
                        guard let email = authUser.email else {
                            print("**** Erreur: SignUpApple() - Pas d'email")
                            return
                        }
                        
                        let dbuser = try await UsersManager.shared.searchUser(email: email)
                        
                        var userId: String = ""
                        
                        // La branche = nil fonctionne
                        if dbuser == nil {
                            let user = DBUser(auth: authUser) // uid, email, user_id, date
                            userId = user.userId
                            try await UsersManager.shared.createDbUser(user: user) // sans l'image
                            let image = UIImage.init(systemName: "person.circle.fill")!
                            try await UsersManager.shared.updateAvatar(userId: userId, mimage: image) // Storage + maj de l'avatarLink dans le "user" crée
                            print("**** dbuser = nil userId = \(userId)")
                            self.currentUserId = userId
                            print("current1:\(userId)")
                        }
//                        } else {
//                            // Je ne passe jamais là car la fonction signInApple() n'est appelé que quand c'est un nouveau compte
//                            guard let userId = dbuser?.userId else { print("**** signUp - userId = nil"); return }
//                            try await UsersManager.shared.updateId(userId: userId, Id: authUser.uid)
//                            print("**** dbuse != nil userId : \(userId)")
//                            self.currentUserId = userId
//                            print("current2:\(userId)")
//                        }
                        // ---
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
