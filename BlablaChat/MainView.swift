//
//  MainView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

struct MainView: View {
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
