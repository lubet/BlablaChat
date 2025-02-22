//
//  ContentView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//
// LoginEmailView signIn/signUp -> RootView
// dbuser = DBUser(auth)
// Create dbuser
// Create Storage
// Maj user avatarlink
// userDefault id,email,user_id (dbuser.user_id) key: variable user_id


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
        
        // Création de l'Auth
        let authUser = try await AuthManager.shared.createUser(email: email, password: password)

        // Chercher dans "users" pour voir si il n'existe pas (cas d'un nouveau contact)
        var dbuser = try await UsersManager.shared.searchUser(email: email)
        
        if dbuser == nil {
            let user = DBUser(auth: authUser) // uid, email, user_id, date
            try await UsersManager.shared.createDbUser(user: user) // sans l'image
            let image = image ?? UIImage.init(systemName: "person.circle.fill")!
            try await UsersManager.shared.updateAvatar(userId: user.userId, mimage: image) // Storage + maj de l'avatarLink dans le "user" crée
        } else {
            // metre à jour l'uid
            guard let userId = dbuser?.userId else { print("SignUp-Pas de userId"); return }
            try await UsersManager.shared.updateId(userId: userId, Id: authUser.uid)
        }

        // lire le user venant d'être créer avec l'email (pour récupérer avatarLink maj plus haut)
        dbuser = try await UsersManager.shared.searchUser(email: email)
        let uidforkey = authUser.uid

        // save userdefault
        if let encodedData = try? JSONEncoder().encode(dbuser) {
            UserDefaults.standard.set(encodedData, forKey: uidforkey)
        }
        // try await TokensManager.shared.addToken(auth_id: auth_id, FCMtoken: G.FCMtoken)
     }

    
    // TODO l'avatarLink dans la  base est et est differend affiché dant le top de lastMessages
    // Compte qui existe déjà
    func signIn() async throws {
        print("---- Sign In ----")
        
        guard !email.isEmpty, !password.isEmpty else {
            print("SignIn - Pas d'email ni de password")
            return
        }
        
        try await AuthManager.shared.signInUser(email: email, password: password)

        guard (try await UsersManager.shared.searchUser(email: email)) != nil else {
            print("LoginEmailView-signIn: email \(email) non trouvé dans la base Users")
            return
        }

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
