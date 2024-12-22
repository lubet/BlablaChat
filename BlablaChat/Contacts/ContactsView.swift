//
//  ContactsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/12/2024.
//  Selection d'un contact et création dans "Users"

import SwiftUI

@MainActor
class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        contacts = [
            ContactModel(nom: "Leroy", prenom: "Maurice", email: "maurice@leroy.com"),
            ContactModel(nom: "Dugou", prenom: "Robert", email: "robert@dugou.com"),
            ContactModel(nom: "Zorba", prenom: "Robert", email: "alexis@zorba.com"),
        ]
    }
    
    // Contact qui a été selectionné dans la liste
    func createContact(contact: ContactModel) async throws {
        
        // Retrouver le contact dans la liste
        guard let index = contacts.firstIndex(where: { $0.id == contact.id }) else {
            print("createContact - Pas d'email")
            return
        }
        let contact: ContactModel = contacts[index]
        
        guard !contact.email.isEmpty else {
            print("createContact - Pas d'email")
            return
        }

        // Pas d'id (auth) mais un contactId et pas d'avatar pour les contacts
        let contactId = UUID().uuidString
        let userDB = DBUser(id:"", email: contact.email, dateCreated: Date(), avatarLink:"", userId: contactId)
        try await UsersManager.shared.createDbUser(user: userDB)
    }
}

// ------------------------
struct ContactsView: View {

    @StateObject var viewModel: ContactsViewModel = ContactsViewModel()
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(viewModel.contacts) { oneContact in
                ContactRowView(oneContact: oneContact)
                    .onTapGesture {
                        Task {
                            try await viewModel.createContact(contact: oneContact)
                        }
                        presentationMode.wrappedValue.dismiss() // Fermeture de la vue
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
