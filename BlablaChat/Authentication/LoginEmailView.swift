//
//  ContentView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//
// LoginEmailView signIn/signUp -> RootView

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
        
        print("**** Sign Up ****")
        
        guard !email.isEmpty, !password.isEmpty else {
            print("SignUp - Pas d'email ni de password")
            return
        }
        
        // New Auth
        let authUser = try await AuthManager.shared.createUser(email: email, password: password)

        // Si il n'y a pas d'image en mettre une par défaut
        let image: UIImage = image ?? UIImage.init(systemName: "person.circle.fill")!
        // Création de l'avatar dans "Storage", maj de l'avatarLink dans "users",
        let avatarLink = try await UsersManager.shared.updateAvatar(mimage: image)
        
        // Création du user = les valeurs par défault du modéle DBUser + les valeurs de authUser + l'avatarLink
        var dbuser = DBUser(id: authUser.uid, email: authUser.email, avatarLink: avatarLink)
        //print("********* dbuser\(dbuser)")

        // Est ce que le user existe déjà dans "Users"
        let userUsers = try await UsersManager.shared.searchUser(email: email)
        
        // Si le user existe déjà dans la base "Users" je l'utilise
        if userUsers != nil {
            dbuser = userUsers!
        } else {
            // le user n'existe pas dans "Users", je le crée.
            try await UsersManager.shared.createDbUser(user: dbuser) // sans l'image
        }
            
        // UserDefaults - Save user
        print("dbuser:\(dbuser)")
        if let encodedData = try? JSONEncoder().encode(dbuser) {
            UserDefaults.standard.set(encodedData, forKey: "saveuser")
        }

        // try await TokensManager.shared.addToken(auth_id: auth_id, FCMtoken: G.FCMtoken)
     }

    // Compte qui existe déjà
    func signIn() async throws {
        
        print("---- Sign In ----")
        
        guard !email.isEmpty, !password.isEmpty else {
            print("SignIn - Pas d'email ni de password")
            return
        }
        
        try await AuthManager.shared.signInUser(email: email, password: password)

        guard let dbuser = try await UsersManager.shared.searchUser(email: email) else {
            print("LoginEmailView-signIn: email \(email) non trouvé dans la base Users")
            return
        }

        if let encodedData = try? JSONEncoder().encode(dbuser) {
            UserDefaults.standard.set(encodedData, forKey: "saveuser")
        }
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
