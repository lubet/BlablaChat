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
    
    // TODO
    func updateAvatar() async throws {
        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        if let newImageAvatar = newImageAvatar {
           let _ = try await UsersManager.shared.updateAvatar(userId: userId, mimage: newImageAvatar)
        }
        // print("updateAvatar")
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
    
    // TODO
//    func resetPassword() async throws {
//        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }
//
//        
//        
//        guard let email = user.email else {
//            throw URLError(.fileDoesNotExist)
//        }
//        
//        try await UsersManager.shared.resetPassword(email: email)
//    }
//    
//    func updateEmail() async throws {
//        let newEmail = "TODO une view de saisir du nouveau email"
//        try await UsersManager.shared.updateEmail(email: newEmail)
//    }
}

// -----------------------
struct SettingsView: View {
    
    @Binding var showSignInView: Bool
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    var body: some View {
        List {
            Color.theme.background
            // Je m'autorise le logout
            // if viewModel.isMaster {
                //masterSection
            //}

            Section {
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
            } header: {
                Text("Avatar")
                    .font(.headline)
            }
            
            // Le changement de mot de passe ne concerne que ceux qui se sont logés avec email et password
//            if viewModel.authProviders.contains(.email) {
//                // emailSection TODO pour plus tard
//            }
            
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

// TODO désactiver
//extension SettingsView {
//    private var emailSection: some View {
//        Section {
//            Button("Reset du mot de passe") { // TODO
//                Task {
//                    do {
//                        try await viewModel.resetPassword()
//                        print("Reset password")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            .disabled(true)
//            .padding(.horizontal,40)
//            
//            Button("Mise à jour de l'email") { // TODO
//                Task {
//                    do {
//                        try await viewModel.updateEmail()
//                        print("Reset password")
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//            .disabled(true)
//            .padding(.horizontal,40)
//        } header: {
//            Text("Email et mot de passe")
//        }
//    }
//}

//extension SettingsView {
//    private var masterSection: some View {
//        Section {
//            Button {
//                viewModel.signOut()
//                showSignInView = true
//            } label: {
//                Text("Log out")
//            }
//            .padding(.horizontal,40)
//        } header: {
//            Text("Logout")
//        }
//    }


