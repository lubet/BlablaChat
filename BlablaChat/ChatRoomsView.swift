//
//  ChatRoomsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 13/02/2024.
//
// Liste des derniers échanges en cours par chatroom

import SwiftUI

struct ChatRoomsView: View {
    var body: some View {
        TabView {
                HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
            Text("Ajouter un contact")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Contact")
                        .foregroundColor(.black)
                }
            Text("Créer un groupe de contact")
                .tabItem {
                    Image(systemName: "person.3")
                }
        }
    }
}

struct ChatRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomsView()
    }
}

struct HomeView: View {

    let contacts = ["Durand","Dupont","Leroy","Dugenou"]
    
    var body: some View {

        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(contacts, id:\.self) { contact in
                        NavigationLink(value: contact) {
                            Text("Click me: \(contact)")
                        }
                    }
                    .font(.title)
                }
            }
            .navigationTitle("Mon email")
            .navigationDestination(for: String.self) {value in
                Text("My second screen\(value)")
            }
        }
    }
}
