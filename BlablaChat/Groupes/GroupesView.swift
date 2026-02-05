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
        contacts.append(ContactModel(nom: "Leroy", prenom: "Marcel", email: "mleroy@test.com", isChecked: false))
        contacts.append(ContactModel(nom: "Gured aaaaaaa", prenom: "Robert", email: "rgured@test.com", isChecked: true))
        contacts.append(ContactModel(nom: "Dujou",prenom: "Roger", email: "rdujou@test.com", isChecked: true))
        contacts.append(ContactModel(nom: "Lafon",prenom: "Albert", email: "alafon@test.com", isChecked: false))
    }
    
}

struct GroupesView: View {
    
    @Environment(\.router) var router
    
    @StateObject var viewModel: GroupesViewModel = GroupesViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            List {
                ForEach(viewModel.contacts) { oneContact in
                    GroupesRowView(oneContact: oneContact)
                }
            }
        }
    }
}

#Preview {
    GroupesView()
}
