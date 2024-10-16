//
//  SettingsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/04/2024.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var httpAvatar: String = ""
    
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    @Published var nom: String = ""
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    return
                }
            }
        }
    }
    
    func logOut() throws {
        try AuthManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthManager.shared.resetPassword(email: email)
    }
    
    func getAvatar() async {
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = authUser.uid
        // Recherche de l'avatar dans users
        httpAvatar = try! await UsersManager.shared.getAvatar(contact_id: user_id)
        // print("\(httpAvatar)")
    }
    
    // Mise à jour de l'avatar dans "Storage" et dans "users" TODO voir si on peut mettre à jour au lieu de supprimer/ajouter
    func updateAvatar() async throws {
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = authUser.uid
        guard let selectedImage else { return }
        
        // Supprimer l'ancien avatar dans "Storage"
        try await StorageManager.shared.deleteAvatar(httpAvatar: httpAvatar)
        
        // Créer le nouvel avatar
        let (path, _) = try await StorageManager.shared.saveImage(image: selectedImage, userId: user_id) // "Storage"
        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        try await UsersManager.shared.updateImagePath(userId: user_id, path: lurl.absoluteString) // maj "Users"
    }
    
    func saveNom() async throws {
        if nom.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return
        } else {
            guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
            let user_id = authUser.uid
            try await TokensManager.shared.saveNom(user_id: user_id, nom: nom)
        }
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack() {
            VStack(spacing: 40) {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.logOut()
                            showSignInView = true
                            return
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding(.top,10)
                
                Button("Reset du mot de passe") {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding(.bottom,10)

                PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                    Text("Changer d'avatar")
                }
                
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                } else {
                    WebImage(url: URL(string: viewModel.httpAvatar))
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                }
                
                // Update du nom
                TextField("Nom", text: $viewModel.nom)
                    .frame(width: 100, height: 25)
                   .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.top,40)
                
                Spacer()
            }
            .onAppear {
                Task {
                    await viewModel.getAvatar()
                }
            }
            .onDisappear {
                Task {
                    try await viewModel.updateAvatar()
                    try await viewModel.saveNom()
                }
            }
        }
    }
    
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView(showSignInView: .constant(false))
        }
    }
}
