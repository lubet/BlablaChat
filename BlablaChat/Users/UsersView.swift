//
//  UsersView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/12/2024.
//

import SwiftUI
import Contacts

@MainActor
final class UsersViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    
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
    }
}

struct UsersView: View {
    
    @StateObject var vm = UsersViewModel()
    
    var body: some View {
            VStack {
                List {
                    ForEach(vm.contacts, id: \.self) { item in
                        UserRowView(contact: item)
                    }
                }
                .navigationTitle("Contacts")
                .onAppear {
                    vm.fetchContacts()
                }
            }
    }
}

#Preview {
    UsersView()
}

