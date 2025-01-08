//
//  UsersView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/12/2024.
//

import SwiftUI

@MainActor
final class UsersViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    
    
    func fetchContacts() {
        contacts.append(ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
        contacts.append(ContactModel(prenom: "Robert", nom: "Gured", email: "rgured@test.com"))
        contacts.append(ContactModel(prenom: "Roger", nom: "Dujou", email: "rdujou@test.com"))
    }
}

struct UsersView: View {
    
    @StateObject var vm = UsersViewModel()
    
    var body: some View {
        List {
            ForEach(vm.contacts, id: \.self) { item in
                UserRowView(email: item.email)
            }
        }
        .navigationTitle("Contacts")
        .onAppear {
            vm.fetchContacts()
        }
    }
}

#Preview {
    UsersView()
}

