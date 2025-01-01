//
//  NewContacts.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/12/2024.
//
// Ios18

//
//  ContentView.swift
//  BlablaContacts
//
//  Created by Lubet-Moncla Xavier on 02/12/2024.
//

import SwiftUI
import ContactsUI

struct NewContacts: View {
    // We hold all our loaded contacts here
    @State private var allContacts = [CNContact]()

    // Whatever the user is currently looking for
    @State private var searchText = ""

    // Results from our existing contacts list
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            allContacts
        } else {
            allContacts.filter {
                $0.givenName.localizedStandardContains(searchText)
                || $0.familyName.localizedStandardContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List(filteredContacts) { contact in
                    NavigationLink("\(contact.givenName)") {
                        UsersView()
                    }
                    // Text("Say hello to \(contact.givenName)")
                }
                .searchable(text: $searchText)

                // This will automatically show a contact if one is matched, or a Search button otherwise
                ContactAccessButton(queryString: searchText) { results in
                    // Run fetchContacts(with:) when a contact is selected
                    fetchContacts(with: results)
                }
                .padding()
            }
        }
    }

    // Converts an array of contact identifiers into actual contacts
    func fetchContacts(with identifiers: [String]) {
        Task {
            // Prepare the Contacts system to return the names of matching people
            let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
            fetchRequest.predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)

            // Store new contacts in this array
            var newContacts = [CNContact]()

            try CNContactStore().enumerateContacts(with: fetchRequest) { contact, _ in
                newContacts.append(contact)
            }

            // Load is completed, so add the new contacts to our existing array
            allContacts += newContacts
        }
    }
}

#Preview {
    NewContacts()
}

