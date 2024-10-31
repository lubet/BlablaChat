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
    
    @Published var httpAvatar: String = ""
    @Published var newImageAvatar: UIImage? = nil
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAvatar() async throws {
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = authUser.uid
        httpAvatar = try! await UsersManager.shared.getAvatar(contact_id: user_id)
    }
    
    // TODO
    func updateAvatar() async throws {
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = authUser.uid
        if let newImageAvatar = newImageAvatar {
            try await UsersManager.shared.updateAvatar(userId: user_id, mimage: newImageAvatar)
        }
    }
    
    func loadAuthProviders() {
        if let providers = try? AuthManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    //    func linkGoogleAccount() async throws {
    //        let helper = SignInGoogleHelper()
    //        let tokens = try await helper.signIn()
    //        let authDataResult = try await AuthManager.shared.linkGoogle(tokens: tokens)
    //        self.AuthUser = authDataResult
    //    }
    //
    //    func linkAppleAccount() async throws {
    //        let helper = SignInAppleHelper()
    //        let tokens = try await helper.startSignInWithAppleFlow()
    //        let authDataResult = try await AuthManager.shared.linkApple(tokens: tokens)
    //        self.authUser = authDataResult
    //    }
    //
    //    // TODO ecran de login
    //    func linkEmailAccount() async throws {
    //        let email = "hello@test.com"
    //        let password = "azerty"
    //        let authDataResult = try await AuthManager.shared.linkEmail(email: email, password: password)
    //        self.authUser = authDataResult
    //    }
    
    func signOut() {
        try? AuthManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthManager.shared.resetPassword(email: email)
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
            // TODO Bouton Log out à supprimer car le choix du login se fait une seule fois à l'installation
            Section (
                header: Text("Log out")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.largeTitle)
                    .fontWeight(.heavy))
            {
                Button {
                    viewModel.signOut()
                    showSignInView = true
                } label: {
                    Text("Log out")
                }
            }
            
            Section (
                header: Text("Avatar")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.largeTitle)
                    .fontWeight(.heavy))
            {
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
            }
            
            Section (
                header: Text("Logins")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.largeTitle)
                    .fontWeight(.heavy))
            {
                // Current user = email
                // if viewModel.authProviders.contains(.email) {
                emailSection
                //}
            }
            
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
        .navigationBarTitle("Paramètres")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
                Button("Changer de mot de passe") { // TODO
                    Task {
                        do {
                            try await viewModel.resetPassword()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                }
                .padding(.horizontal,40)
        }
    }
}
