//
//  GroupesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 04/02/2026.
//  Groupes de contacts

import SwiftUI

@MainActor
class GroupesViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    
    init() {
        fetchAllContacts()
    }
    
    private func fetchAllContacts() {
        contacts.append(ContactModel(nom: "Leroy", prenom: "Marcel", email: "mleroy@test.com"))
        contacts.append(ContactModel(nom: "Gured aaaaaaa", prenom: "Robert", email: "rgured@test.com"))
        contacts.append(ContactModel(nom: "Dujou",prenom: "Roger", email: "rdujou@test.com"))
        contacts.append(ContactModel(nom: "Lafon",prenom: "Albert", email: "alafon@test.com"))
    }
    
}

struct GroupesView: View {
    
    @Environment(\.router) var router
    
    @StateObject var viewModel: GroupesViewModel = GroupesViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            List {
                ForEach(viewModel.contacts, id: \.self) { oneContact in
                    ContactsRowView(oneContact: oneContact)
                }
            }
        }
    }
}

#Preview {
    GroupesView()
}
