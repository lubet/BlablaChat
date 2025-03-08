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
        
        // Récupérr l'email de l'auth existant
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { print("authUser nil; return "); return }
        guard let email = authUser.email else { print("appleAfterSignUp() email nil"); return }
        
        let dbuser = try await UsersManager.shared.searchUser(email: email)

        if dbuser == nil {
            print("**** SignUp Apple noueau user")
            let user = DBUser(auth: authUser) // uid, email, user_id, date
            try await UsersManager.shared.createDbUser(user: user) // sans l'image
            let image = UIImage.init(systemName: "person.circle.fill")!
            try await UsersManager.shared.updateAvatar(userId: user.userId, mimage: image) // Storage + maj de l'avatarLink dans le "user" crée
            self.currentUserId = user.userId
        } else {
            // Existe déjà - maj de l'uid
            print("**** SignUp Apple user existant dans users")
            guard let userId = dbuser?.userId else { print("**** signUp - userId = nil"); return }
            try await UsersManager.shared.updateId(userId: userId, Id: authUser.uid)
            self.currentUserId = userId
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
