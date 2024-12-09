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
    
    // Contact qui a été selectionné dans la liste
    func selectContact(contact: ContactModel) {
        
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            // on récupére ici l(index du contact que l'on a selectionée
            let contact: ContactModel = contacts[index]
        }
        
        print("\(contact)")
    }
    
}


struct ContactsView: View {

    @StateObject var viewModel: ContactsViewModel = ContactsViewModel()
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(viewModel.contacts) { oneContact in
                ContactRowView(oneContact: oneContact)
                    .onTapGesture {
                        viewModel.selectContact(contact: oneContact)
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
