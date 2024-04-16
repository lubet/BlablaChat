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
            TabView {
                    LastMessagesView()
                    .tabItem {
                        Image(systemName: "tray.and.arrow.down.fill")
                        Text("Courrier Entrant")
                    }
                    Text("Courrier sortant")
                    .tabItem {
                        Image(systemName: "tray.and.arrow.up.fill")
                        Text("Courrier Entrant")
                    }
                    SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Paramètres")
                    }
            }
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
