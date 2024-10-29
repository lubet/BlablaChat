//
//  ContentView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import SwiftUI

@MainActor
final class LoginEmailViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""

    func signUp(image: UIImage?) async throws {
        
        guard !email.isEmpty, !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        
        // Création de l'authetification de Firebase
        let authUser = try await AuthManager.shared.createUser(email: email, password: password)
        
        // Création d'un profil de base dans "users"
        let user = DBUser(auth: authUser) // userId, email
        try await UsersManager.shared.createDbUser(user: user) // sans l'image
        
        guard let image else { return }
        
        // Avatar
        try await UsersManager.shared.updateAvatar(userId: user.userId, mimage: image)
        
//        let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: user.userId)
//
//        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
//
//        try await UsersManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore
        
     }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
    
    func FCMtoken() async throws {
        // Sauvegarde du FCMtoken dans Firestore
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = authUser.uid
        
        try await TokensManager.shared.addToken(user_id: user_id, FCMtoken: MyVariables.FCMtoken)
    }
    
    
    // Lier le provider email au user en cours (si c'est aussi un email ?)
    
}

// -----------------------------------------------------
struct LoginEmailView: View {
    
    @StateObject private var viewModel = LoginEmailViewModel()
    
    @Binding var showSignInView: Bool
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            VStack {
                
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
                            Image(systemName: "person.fill")
                                .font(.system(size: 70))
                                .padding()
                                .foregroundColor(Color(.label))
                        }
                    }
                    .overlay(RoundedRectangle(cornerRadius: 64)
                        .stroke(Color.black,lineWidth: 2))
                    
                }
                .padding(.bottom,20)
                
                TextField("Email", text: $viewModel.email)
                    .padding(15)
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .padding(15)
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .disableAutocorrection(true)
                
                    .padding(10)
                
                    .padding(.bottom,40)
                
                Button { // Entrée
                    Task {
                        do {
                            // On essaie de créer le compte
                            let mimage: UIImage = image ?? UIImage.init(systemName: "person.fill")!
                            try await viewModel.signUp(image: mimage)
                            try await viewModel.FCMtoken()
                            showSignInView = false
                            return
                        } catch {
                            // erreur
                            // Le compte existe déjà -> on passe à la suite
                        }
                        // Le compte existe déjà
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
            
            // Image
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                ImagePicker(image: $image) // Utilities/ImagePicker
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginEmailView(showSignInView: .constant(false))
    }
}
