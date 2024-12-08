//
//  ContactsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/12/2024.
//

import SwiftUI

@MainActor
class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        contacts = [
            ContactModel(nom: "Leroy", prenom: "Maurice", emai: "maurice@leroy"),
            ContactModel(nom: "Dugou", prenom: "Robert", emai: "robert@dugou"),
        ]
    }
    
    func updateUser(contact: ContactModel) {
        
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            // on récupére ici l(index du contact que l'on a selectionée
            let selectedContact: ContactModel = contacts[index]
        }
    }
    
}


struct ContactsView: View {

    @StateObject var viewModel: ContactsViewModel = ContactsViewModel()

    var body: some View {
        List {
            ForEach(viewModel.contacts) { oneContact in
                ContactRowView(oneContact: oneContact)
                    .onTapGesture {
                        viewModel.updateUser(contact: oneContact)
                    }
            }
        }
        .navigationTitle("Liste")
    }
}

#Preview {
    NavigationView {
        ContactsView()
    }
}
