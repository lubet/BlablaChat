//
//  ContentView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import SwiftUI

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
        let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: user.userId)
//        print("image path: \(path)") // chemin complet + nom du jpeg
//        print("Image name: \(name)") // nom du jpeg

        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        // print("image url: \(lurl)")

        try await UsersManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore
        
     }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
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
                .padding(40)
                
                TextField("Email", text: $viewModel.email)
                    .padding(15)
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                TextField("Mot de passe", text: $viewModel.password)
                    .padding(15)
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .disableAutocorrection(true)
                
                Button { // SignIn - le user existe
                    Task {
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
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                } // Fin bouton signIn
                
                Spacer()
                
                Button { // SignUp - Nouveau user
                    Task {
                        do {
                            // Nouveau compte
                            let mimage: UIImage = image ?? UIImage.init(systemName: "person.fill")!
                            try await viewModel.signUp(image: mimage) // Création ou non (si il existe déjà)
                            showSignInView = false
                            return
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
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
