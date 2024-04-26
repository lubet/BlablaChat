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
            LastMessagesView()
//            TabView {
//                LastMessagesView()
//                    .tabItem {
//                        Image(systemName: "tray.full")
//                    }
//                MesContactsView()
//                    .tabItem {
//                        Image(systemName: "person.2.fill")
//                    }
//            }
            // SettingsView(showSignInView: $showSignInView)
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
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
