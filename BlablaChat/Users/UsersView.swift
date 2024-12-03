//
//  UsersView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 31/07/2024.
//

import SwiftUI
import ContactsUI

// ---------------------
struct UsersView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
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

    let didSelectedNewUser: (String) -> () // call back

    var body: some View {
        NavigationStack {
            VStack {
                List(filteredContacts) { contact in
                    Text("Say hello to \(contact.givenName)")
                        Button {
                            presentationMode.wrappedValue.dismiss() // Fermeture de la vue
                            didSelectedNewUser(contact.givenName)      // Ouverture de la vue précédente "NewMessagesView" avec passage de l'email selectionné
                        } label: {
                            // UsersCellView(oneUser: oneUser)
                        }

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
    
    
    
    
    //        ZStack {
    //            Color.theme.background
    //            NavigationStack {
    //                List {
    //                    ForEach(filteredUsers) { oneUser in
    //                        Button {
    //                            presentationMode.wrappedValue.dismiss() // Fermeture de la vue
    //                            didSelectedNewUser(oneUser.email!)      // Ouverture de la vue précédente "NewMessagesView" avec passage de l'email selectionné
    //                        } label: {
    //                            UsersCellView(oneUser: oneUser)
    //                        }
    //                    }
    //                }
    //                .searchable(text: $searchTerm, prompt: "Recherche d'un contact")
    //                .autocorrectionDisabled(true)
    //                .textInputAutocapitalization(.never)
    //                .disableAutocorrection(true)
    //                .task {
    //                    await viewModel.loadUsers()
    //                }
    //                .listStyle(PlainListStyle())
    //                .navigationTitle("Participants")
    //                .padding(.top,10)
    //                .toolbar {
    //                    ToolbarItem(placement: .navigationBarLeading) {
    //                        Button {
    //                            presentationMode.wrappedValue.dismiss()
    //                        } label: {
    //                            Image(systemName: "xmark")
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //    }
    //}
    
    //#Preview {
    //    UsersView(didSelectedNewUser: ())
    //}
}

//#Preview {
//    UsersView()
//}
