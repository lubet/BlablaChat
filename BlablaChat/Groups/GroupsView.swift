//
//  GroupsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/08/2025.
//

import SwiftUI
import Contacts

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var sortedContacts: [Contact] = []

    init() {
        loadData()
    }
    
    func loadData() {
                contacts.append(Contact(nom: "Leroy", prenom: "Marcel", email: "mleroy@test.com"))
                contacts.append(Contact(nom: "Gured", prenom: "Robert", email: "rgured@test.com"))
                contacts.append(Contact(nom: "Dujou", prenom: "Roger", email: "rdujou@test.com"))
                contacts.append(Contact(nom: "Lafon", prenom: "Albert", email: "alafon@test.com"))
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
                    contacts.append(Contact(nom: nom, prenom: prenom, email: email))
                }
            })
            sortedContacts = contacts.sorted { $0.nom < $1.nom}
         }
        catch let erreur {
            print(erreur)
        }
    }
}

struct GroupsView: View {
    
    @StateObject var vm: GroupsViewModel = GroupsViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.background
            List {
                ForEach(vm.contacts) { item in
                    Text(item.nom)
                }
            }
        }
    }
}

#Preview {
    GroupsView()
}
