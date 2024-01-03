//
//  ContentView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import SwiftUI

final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""

    func signUp(image: UIImage?) {
        guard !email.isEmpty, !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        AuthManager.shared.createUser(email: email, password: password)
        
        let authUser = try? AuthManager.shared.getCurrentUser()
        
        guard let uid = authUser?.uid else { return }

        guard let image else { return }
        
        StorageManager.shared.persistImageToStorage(image: image, userId: uid)
        
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("Pas d'email ni de password")
            return
        }
        AuthManager.shared.signInUser(email: email, password: password)
    }
    
}

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
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
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    
                    Button {
                        viewModel.signUp(image: image) // Création si il n'existe pas déjà)
                        
                        viewModel.signIn() // Dans tous les cas le user existe (vient d'être créer ou existait déjà)
                    } label: {
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
        }
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
        LoginView()
    }
}
