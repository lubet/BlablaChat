//
//  ContentView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//
// SignUp: nouveau user ou user non authentifié (cad venant de contacts)
// SignIn: user identifié

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

@MainActor
final class LoginEmailViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var httpAvatar: String = ""
    @Published var newImageAvatar: UIImage? = nil
    
    
    // Nouveau compte - Auth, Users, Tokens - Si déjà présent dans "Users" (contact) prendre le userId existant
    func signUp(image: UIImage?) async throws {

        guard !email.isEmpty, !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        
        // Connection Firebase
        let authUser = try await AuthManager.shared.createUser(email: email, password: password)

        // Chercher dans "users" pour voir si il n'existe pas (cas d'un nouveau contact)
        var dbuser = try await UsersManager.shared.searchUser(email: email)
        
        if dbuser == nil {
            let user = DBUser(auth: authUser) // uid, email, user_id, date
            try await UsersManager.shared.createDbUser(user: user) // sans l'image
            let image = image ?? UIImage.init(systemName: "person.circle.fill")!
            try await UsersManager.shared.updateAvatar(userId: user.userId, mimage: image) // Storage + maj de l'avatarLink dans le "user" crée
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
        
        print("**** SignUp - dbuser: \(String(describing: dbuser))")
        
        // try await TokensManager.shared.addToken(auth_id: auth_id, FCMtoken: G.FCMtoken)
     }

    
    // "user" existant dans la base
    func signIn() async throws {
        
        print("---- Sign In ----")
        
        guard !email.isEmpty, !password.isEmpty else {
            print("**** SignIn - Pas d'email ni de password")
            return
        }
        
        // Connection Firebase
        try await AuthManager.shared.signInUser(email: email, password: password)

        // Recherche du user
        guard let dbuser = try await UsersManager.shared.searchUser(email: email) else {
            print("**** SignIn - Pas de dbuser")
            return
        }

        // Je sauve le user sur le disque
        if let encodedData = try? JSONEncoder().encode(dbuser) {
            UserDefaults.standard.set(encodedData, forKey: "saveuser")
        }
        
        // Je lis le user qui vient d'être créer sur le disque
        let user = try UsersManager.shared.getUserDefault()
        httpAvatar = user.avatarLink ?? ""
        
        return
    }
}

// -----------------------------------------------------
struct LoginEmailView: View {
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    @StateObject private var viewModel = LoginEmailViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            VStack {
                // Avatar
                Button { // Avatar
                    showImagePicker.toggle()
                } label: {
                    VStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            WebImage(url: URL(string: viewModel.httpAvatar))
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .overlay(RoundedRectangle(cornerRadius: 64)
                        .stroke(Color.black,lineWidth: 2))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom,40)

                
                TextField("Email", text: $viewModel.email)
                    .padding(15)
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .background(Color.theme.backtext)
                    .foregroundColor(Color.theme.forground)
                    .cornerRadius(10)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .padding(15)
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .background(Color.theme.backtext)
                    .foregroundColor(Color.theme.forground)
                    .cornerRadius(10)
                    .disableAutocorrection(true)
                
                    .padding(10)
                
                    .padding(.bottom,40)
                
                Button { // Entrée
                    Task {
                        do {
                            // Nouveau compte
                            try await viewModel.signUp(image: image) // Création de l'auth, du user et du token.
                            showSignInView = false
                            return
                        } catch {
                            // Le compte existe déjà -> on passe à la suite cad à l'ancien compte
                        }
                        do {
                            // Ancien compte
                            try await viewModel.signIn()
                            showSignInView = false
                            return
                        } catch {
                            print("Erreur signIn:", error)
                        }
                    }
                } label: {
                    Text("Entrée")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                } // Fin bouton signIn
            }
            .padding()
        }
        // Image
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image) // Utilities/ImagePicker
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginEmailView(showSignInView: .constant(false))
//    }
//}
