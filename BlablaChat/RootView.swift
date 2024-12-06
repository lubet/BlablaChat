//
//  MainView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//
// Essai

import SwiftUI

struct RootView: View {

    @State private var showSignInView: Bool = true
    
    var body: some View {
        ZStack {
            if showSignInView == false {
                LastMessagesView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            if let authUser = try? AuthManager.shared.getAuthenticatedUser() {
                self.showSignInView = false
            } else {
                self.showSignInView = true
            }
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
