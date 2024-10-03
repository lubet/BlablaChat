//
//  SettingsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/04/2024.
//

import SwiftUI
import SDWebImageSwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var httpAvatar: String = ""
    
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
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @Binding var showSignInView: Bool
    
    @State var image: UIImage?
    
    @State var showImagePicker: Bool = false
    
    
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
                
                // Recherche l'avatar du user
                // L'afficher
                Button { // Avatar
                    showImagePicker.toggle()
                } label: {
                    VStack {
                        WebImage(url: URL(string: viewModel.httpAvatar))
                            .resizable()
                            .frame(width:120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            .padding()

//                           .overlay(RoundedRectangle(cornerRadius: 64))
//                         .stroke(Color.black,lineWidth: 2)
                    }
                }
                Spacer()
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
