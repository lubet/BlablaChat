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
            LastMessagesView() // Dernier messages de chaque rooms
                .tabItem {
                    Image(systemName: "message")
                    Text("Rooms/Messages")
                }
            MessagesView() // Messages d'un room
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Conversations")
                }
            
            NewContactView() // Contacts
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Contact")
                        .foregroundColor(.black)
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
