//
//  ContactsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 20/04/2024.
//
// Liste des contacts avec barre supérieur de recherche


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

@MainActor
final class ContactsViewModel: ObservableObject {
    
    @Published private(set) var mesContacts: [Contact] = []
    @Published private(set) var filteredContacts: [Contact] = []
    @Published var searchText: String = ""
    
    private var cancellable = Set<AnyCancellable>()

    var isSearching: Bool {
        !searchText.isEmpty
    }

    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.filterContacts(searchText: searchText)
            }
            .store(in: &cancellable)
    }

    private func filterContacts(searchText: String) {
        guard !searchText.isEmpty else {
            filteredContacts = []
            return
        }
        
        let search = searchText.lowercased()
        filteredContacts = mesContacts.filter({ contact in
            let emailContainsSearch = contact.nom.lowercased().contains(search)
            let messageContainsSearch = contact.email.lowercased().contains(search)
            return emailContainsSearch || messageContainsSearch
        })
    }
    
    func getContacts() async {
        self.mesContacts = await ContactManager.shared.mockContacts()
    }
}

// ------------------------------------------------------------------

struct ContactsView: View {
    
    @StateObject var viewModel = ContactsViewModel()
    
    @State private var searchText: String = ""
    @State private var messageTexte: String = ""

    @Binding var path: NavigationPath //
    
    var body: some View {
        List {
            ForEach(viewModel.isSearching ? viewModel.filteredContacts : viewModel.mesContacts, id: \.self) { oneContact in
                NavigationLink(value: oneContact) {
                    ContactCellView(lecontact: oneContact)
                }

            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher un contact")
        .navigationTitle("Contacts")
        .task { await viewModel.getContacts() }
        Spacer()
            .navigationDestination(for: Contact.self) { value in
                MesContactsView()
            }
    }
}

//struct ContactsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactsView(path:NavigationPath())
//    }
//}
