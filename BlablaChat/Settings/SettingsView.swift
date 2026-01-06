//
//  SettingsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/10/2024.
//

import SwiftUI
import PhotosUI
import SDWebImage
import SDWebImageSwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @AppStorage("currentUserId") var currentUserId: String?
    
    @Published var httpAvatar: String = ""
    @Published var newImageAvatar: UIImage? = nil
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAvatar() async throws {
        guard let currentUserId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        httpAvatar = try! await UsersManager.shared.getAvatar(contact_id: currentUserId)
        print("loadAvatar: \(httpAvatar)")
    }
    
    func updateAvatar() async throws {
        guard let currentUserId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        if let newImageAvatar = newImageAvatar {
           let _ = try await UsersManager.shared.updateAvatar(userId: currentUserId, mimage: newImageAvatar)
            print("updateAvatar")
        }
    }
    
    func signOut() {
        try? AuthManager.shared.signOut()
    }
}

// -----------------------
struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    var body: some View {
             // Color.theme.background.ignoresSafeArea()
        VStack {
            Button {
                showImagePicker.toggle()
            } label: {
                VStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200, alignment: .center)
                            .clipShape(Circle())
                    } else {
                        WebImage(url: URL(string: viewModel.httpAvatar))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200, alignment: .center)
                            .clipShape(Circle())
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.black,lineWidth: 2))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }

        // Image
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
        .onAppear {
            Task {
                try await viewModel.loadAvatar()
            }
        }
        .onDisappear { 
            viewModel.newImageAvatar = image
            print("***** Disappear début")
            Task {
                try await viewModel.updateAvatar()
            }
            print("***** Disappear fin")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
