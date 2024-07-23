//
//  SettingsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/04/2024.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func logOut() throws {
        try AuthManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        print("email:\(email)")
        try await AuthManager.shared.resetPassword(email: email)
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @Binding var showSignInView: Bool
    
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    print("****** Logout")
                    do {
                        try viewModel.logOut()
                        showSignInView = true
                        return
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Reset du mot de passe") {
                Task {
                    print("****** Reset mot de passe")
                    do {
                        try await viewModel.resetPassword()
                        print("PAssword resset")
                    } catch {
                        print(error)
                    }
                }
            }

        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showSignInView: .constant(false))
    }
}
