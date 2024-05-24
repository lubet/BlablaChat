//
//  LoginView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 24/05/2024.
//

import SwiftUI

final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    func signUp() async throws {
        
        guard !email.isEmpty, !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        
        let authUser = try await AuthManager.shared.createUser(email: email, password: password)
        
        let user = DBUser(auth: authUser) // Instanciation userId email
        
        try await UserManager.shared.createDbUser(user: user) // Save in Firestore sans l'image
        
//        guard let image else { return }
//        
//        let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: user.userId)
////        print("image path: \(path)") // chemin complet + nom du jpeg
////        print("Image name: \(name)") // nom du jpeg
//
//        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
//        // print("image url: \(lurl)")
//
//        try await UserManager.shared.updateImagePath(userId: user.userId, path: lurl.absoluteString) // maj Firestore
        
     }
    
    func signIn() async throws {
        guard !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        try await AuthManager.shared.signInUser(email: email, password: password)
    }
}

// View ------------------------------------------------
struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        
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
        
        Button { // Trigger
            Task {
                do {
                    // Nouveau compte
                    // let mimage: UIImage = image ?? UIImage(named: "MaPhoto")!
                    try await viewModel.signUp() // Création ou non (si il existe déjà)
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


    }
}

#Preview {
    LoginView(showSignInView: .constant(false))
}
