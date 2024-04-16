//
//  MainView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

struct RootView: View {

    @State private var showSignInView: Bool = false
    
    var body: some View {
        ZStack {
                // LastMessagesView()
            SettingsView(showSignInView: $showSignInView)
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
