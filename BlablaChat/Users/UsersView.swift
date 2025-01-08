//
//  UsersView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/12/2024.
//

import SwiftUI

@MainActor
final class UsersViewModel: ObservableObject {
    
    func fetchContacts() {
        
    }
}

struct UsersView: View {
    var body: some View {
        List {
            UserRowView(nom: "Maurice Leroy")
        }
        .navigationTitle("Contacts")
    }
}

#Preview {
    UsersView()
}

