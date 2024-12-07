//
//  ContactsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 07/12/2024.
//

import SwiftUI
import ContactsUI

@MainActor
class ContactsViewModel: ObservableObject {
    
    // We hold all our loaded contacts here
    @Published var allContacts = [CNContact]()
    
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

struct ContactsView: View {
    
    @StateObject var viewModel: ContactsViewModel = ContactsViewModel()

    // Whatever the user is currently looking for
    @State private var searchText = ""

    // Results from our existing contacts list
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            viewModel.allContacts
        } else {
            viewModel.allContacts.filter {
                $0.givenName.localizedStandardContains(searchText)
                || $0.familyName.localizedStandardContains(searchText)
            }
        }
    }

    
    var body: some View {
        Text("Hello")
        
        VStack {
            List(filteredContacts) { contact in
                Text("Say hello to \(contact.givenName)")
            }
            .searchable(text: $searchText)

            // This will automatically show a contact if one is matched, or a Search button otherwise
            ContactAccessButton(queryString: searchText) { results in
                // Run fetchContacts(with:) when a contact is selected
                viewModel.fetchContacts(with: results)
            }
            .padding()
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactsView()
        }
    }
}

