//
//  UsersView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/12/2024.
//
// Liste des contactes du carnet d'adresses
// Selection d'un contact
// Passage du contact à la view Messages
//
// ContactsView -> MessagesView
//

import SwiftUI
import Contacts

@MainActor
final class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    @Published var searchText: String = ""
    
    // Recherche contacts
    var filteredContacts: [ContactModel] {
        guard !searchText.isEmpty else { return contacts}
        return contacts.filter { oneContact in
            oneContact.nom.lowercased().contains(searchText.lowercased())
        }
    }
    
    init() {
        fetchContacts()
    }
    
    func fetchAllContacts() {
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock:
                                            {(contact, stop) in
                let email = contact.emailAddresses.first?.value.description ?? ""
                let prenom = contact.givenName
                let nom = contact.familyName
                if ((prenom != "" || nom != "") && email != "") {
                    contacts.append(ContactModel(prenom: prenom, nom: nom, email: email))
                }
                print(contact.givenName)
                print(contact.familyName)
                print(contact.emailAddresses.first?.value.description ?? "")
            })
         }
        catch let erreur {
            print(erreur)
        }
    }
    
    func fetchContacts() {
        contacts.append(ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
        contacts.append(ContactModel(prenom: "Robert", nom: "Gured", email: "rgured@test.com"))
        contacts.append(ContactModel(prenom: "Roger", nom: "Dujou", email: "rdujou@test.com"))
        contacts.append(ContactModel(prenom: "Albert", nom: "Lafon", email: "alafon@test.com"))
    }
}

struct ContactsView: View {
    
    @StateObject var vm = ContactsViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    let didSelectedNewUser: (String) -> () // -> retour à LastMessagesView -> Bubbles
    
    var body: some View {
        ZStack {
            Color.theme.background
            NavigationStack {
                List {
                    ForEach(vm.filteredContacts, id: \.self) { oneContact in
                        Button {
                            presentationMode.wrappedValue.dismiss() // Fermeture de la vue
                            // -> LastMessagesView -> BubblesView
                            didSelectedNewUser(oneContact.email)
                        } label: {
                            ContactRowView(oneContact: oneContact)
                        }
                    }
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(systemName: "xmark")
                            .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .searchable(text: $vm.searchText)
            }
        }
    }
}

//#Preview {
//    ContactsView(salonId: "E")
//}

