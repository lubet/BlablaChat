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
    
    @AppStorage("currentUserId") var currentUserId: String?
    
    @Published var contacts: [ContactModel] = []
    @Published var sortedContacts: [ContactModel] = []
    
    // Recherche contacts
//    var filteredContacts: [ContactModel] {
//        guard !searchText.isEmpty else { return sortedContacts}
//        return contacts.filter { oneContact in
//            oneContact.nom.lowercased().contains(searchText.lowercased())
//        }
//    }
    
    init() {
        fetchAllContacts()
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
            })
            sortedContacts = contacts.sorted { $0.nom < $1.nom}
         }
        catch let erreur {
            print(erreur)
        }
    }
    
//    func fetchContacts() {
//        contacts.append(ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
//        contacts.append(ContactModel(prenom: "Robert", nom: "Gured", email: "rgured@test.com"))
//        contacts.append(ContactModel(prenom: "Roger", nom: "Dujou", email: "rdujou@test.com"))
//        contacts.append(ContactModel(prenom: "Albert", nom: "Lafon", email: "alafon@test.com"))
//    }
}

struct ContactsView: View {
    
    @EnvironmentObject var routerPath: RouterPath
    
    @StateObject var vm = ContactsViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.background
            List {
                ForEach(vm.sortedContacts) { oneContact in
                    //let emailForBubbles: String = oneContact.email
                    
                    NavigationLink(value: oneContact.email) {
                        ContactRowView(oneContact: oneContact)
                    }
                }
            }
            .navigationTitle("Contacts")

// Le navigationDestination de LastMessageView est utilisé car du même type, String.
//            .navigationDestination(for: String.self) { value in
//                    BubblesView(email: value)
//            }
        }
    }
}

#Preview {
    ContactsView()
}

