//
//  MainView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        LastMessagesView() // Dernier messages de chaque rooms
            .tabItem {
                Image(systemName: "message")
                Text("Rooms/Messages")
            }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
