//
//  MainView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            MessagesView() // Liste des conversations
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Conversations")
                }
            
            NewContactView() // Nouveau contact
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Contact")
                        .foregroundColor(.black)
                }
            
            //
            Text("Créer un groupe de contact")
                .tabItem {
                    Image(systemName: "person.3")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
