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
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack() {
            VStack(spacing: 20) {
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
                .padding(.top,20)
                
                Button("Reset du mot de passe") {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding(.bottom,20)
                
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                } else {
                    WebImage(url: URL(string: viewModel.httpAvatar))
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 1))
                }
                
                PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                    Text("Changer d'avatar")
                }
            }
            .onAppear {
                Task {
                    await viewModel.getAvatar()
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
