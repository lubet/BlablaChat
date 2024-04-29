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
    @Published private(set) var filteredContacts: [ListeAllUsers] = []
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
        filteredContacts = listAllUsers.filter({ contact in
            let emailContainsSearch = contact.nom.lowercased().contains(search)
            let messageContainsSearch = contact.email.lowercased().contains(search)
            return emailContainsSearch || messageContainsSearch
        })
    }
    
    // Constituer la liste des contacts du téléphone) + les users de Firestore
    func getUsersAndContacts() async {
        
        self.users = try! await UserManager.shared.getAllUsers()
        for word in users {
            if let email = word.email {
                listAllUsers.append(ListeAllUsers(nom: email, email: "")) // les users n'ont pas de nom (voir le login)
            }
        }

        self.mesContacts = await ContactManager.shared.mockContacts()
        for word in mesContacts {
            // N'ajouter le contact à la liste d'affichage
            if (listAllUsers.filter{$0.email == word.email}.count == 0) {
                listAllUsers.append(ListeAllUsers(nom: word.email, email: word.nom))
            }
        }
        listAllUsers.sort { $0.nom < $1.nom }
    }
}

// ------------------------------------------------------------------

struct ContactsView: View {
    
    @StateObject var viewModel = ContactsViewModel()
    
    @State private var searchText: String = ""
    @State private var messageTexte: String = ""
    
    let didSelectedNewUser: (String) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.isSearching ? viewModel.filteredContacts : viewModel.listAllUsers, id: \.self) { oneItem in
                    Button {
                        presentationMode.wrappedValue.dismiss() // TODO si le contact n'est pas dans users le creer
                        didSelectedNewUser(oneItem.nom)
                    } label: {
                        ContactCellView(oneItem: oneItem)
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

//struct ContactsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactsView()
//    }
//}
