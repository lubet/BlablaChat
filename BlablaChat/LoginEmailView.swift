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
        
        let authUser = try await AuthManager.shared.createUser(email: email, password: password)
        
        let user = DBUser(auth: authUser) // Instanciation userId email
        
        try await UserManager.shared.createDbUser(user: user) // Save in Firestore sans l'image
        
        guard let image else { return }
        
        let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: user.userId)
//        print("image path: \(path)") // chemin complet + nom du jpeg
//        print("Image name: \(name)") // nom du jpeg

        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        // print("image url: \(lurl)")

        try await UserManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore
        
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
        //NavigationView {
            ScrollView {
                VStack {
                    
                    // Avatar
                    Button {
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
                    
                    Group {
                        TextField("Email", text: $viewModel.email)
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Mot de passe", text: $viewModel.password)
                            .cornerRadius(10)
                    }
                    .padding(15)
                    .background(Color.gray.opacity(0.2))
                    
                    // Login
                    Button {
                        Task {
                            do {
                                // Nouveau compte
                                // let mimage: UIImage = image ?? UIImage(named: "MaPhoto")!
                                try await viewModel.signUp(image: image) // Création ou non (si il existe déjà)
                                showSignInView = false
                                return
                            } catch {
                                print(error)
                            }
                        }
                        
                        Task {
                            do {
                                // Ancien compte
                                try await viewModel.signIn() // Dans tous les cas le user existe (vient d'être créer ou existait déjà)
                                showSignInView = false
                                return
                            } catch {
                                showSignInView = false
                                return
                            }
                        }                    } label: {
                        Text("Sign In/Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    } // Fin bouton
                    
                    Spacer()
                }
            }
        //}
        .background(Color(.init("GrisClair")))
        .padding()
        // Image
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image) // Utilities/ImagePicker
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginEmailView(showSignInView: .constant(false))
    }
}
