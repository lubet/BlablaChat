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

struct ListeAllUsers: Identifiable, Hashable {
    let id = UUID().uuidString
    let nom: String
    let email: String
    
    init (nom: String, email: String)
    {
        self.nom = nom
        self.email = email
    }
}

@MainActor
final class ContactsViewModel: ObservableObject {
    
    @Published private(set) var mesContacts: [Contact] = []
    @Published private(set) var filteredContacts: [Contact] = []
    private(set) var users: [DBUser] = []
    
    @Published private(set) var listAllUsers: [ListeAllUsers] = []
    
    
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
    
    // Fusionner contactsTel et users uniquement pour la présentation dans la liste
    func getUsersAndContacts() async {
        // ContactsTel nom, email
        self.mesContacts = await ContactManager.shared.mockContacts()
        // Charger les users dans le tableau des users
        self.users = try! await UserManager.shared.getAllUsers()
    }
    
}

// ------------------------------------------------------------------

struct ContactsView: View {
    
    @StateObject var viewModel = ContactsViewModel()
    
    @State private var searchText: String = ""
    @State private var messageTexte: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.isSearching ? viewModel.filteredContacts : viewModel.mesContacts, id: \.self) { oneContact in
                    Button {
                        // si le contact selectionné n'existe pas dans "users" il faut le créer et le remonter à LastMessageView
                        
                        presentationMode.wrappedValue.dismiss() // TODO si le contact n'est pas dans users le creer
                    } label: {
                        ContactCellView(lecontact: oneContact)
                    }
                }
            }
            .navigationTitle("ContactsView")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher un contact")
            .task { await viewModel.getUsersAndContacts() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView()
    }
}
