//
//  SettingsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/10/2024.
//

import SwiftUI
//import PhotosUI
import SDWebImage
import SDWebImageSwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @AppStorage("currentUserId") var currentUserId: String?
    
    @Published var httpAvatar: String = ""
    @Published var newImageAvatar: UIImage? = nil
    @Published var isMaster: Bool = false
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAvatar() async throws {
        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        httpAvatar = try! await UsersManager.shared.getAvatar(contact_id: userId)
    }
    
    func updateAvatar() async throws {
        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        if let newImageAvatar = newImageAvatar {
           let _ = try await UsersManager.shared.updateAvatar(userId: userId, mimage: newImageAvatar)
        }
    }
    
    func loadAuthProviders() {
        if let providers = try? AuthManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() {
        try? AuthManager.shared.signOut()
    }
}

// -----------------------
struct SettingsView: View {
    
    @Binding var showSignInView: Bool
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    var body: some View {
        List {
            // Color.theme.background.ignoresSafeArea()
                Button { // Avatar
                    showImagePicker.toggle()
                } label: {
                    VStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipShape(Circle())
                        } else {
                            WebImage(url: URL(string: viewModel.httpAvatar))
                                .resizable()
                                .frame(width: 120, height: 120, alignment: .center)
                                .clipShape(Circle())
                        }
                    }
                    .overlay(RoundedRectangle(cornerRadius: 64)
                        .stroke(Color.black,lineWidth: 2))
                }
               .frame(maxWidth: .infinity, alignment: .center)
               .background(Color.theme.inputbackground)
                
        }
        
        // Image
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image) // Utilities/ImagePicker
        }
        .onAppear {
            Task {
                try await viewModel.loadAvatar()
            }
            viewModel.loadAuthProviders()
        }
        .onDisappear {
            viewModel.newImageAvatar = image
            Task {
                try await viewModel.updateAvatar()
            }
        }
        .navigationTitle("Paramètres")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false))
    }
}
