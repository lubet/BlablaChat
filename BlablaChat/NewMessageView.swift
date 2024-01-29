//
//  NewMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 26/01/2024.
//

import SwiftUI
import Combine

struct Contact: Identifiable {
    let id: String
    let nom: String
    let prenom: String
    let email: String
}

final class ContactManager {
    
    func getAllContacts() async throws ->
        [Contact] {
        [
            Contact(id: "1", nom: "Dudu", prenom: "Maurice", email: "maurice@test.com"),
            Contact(id: "2", nom: "Dudu", prenom: "Robert", email: "maurice@test.com"),
            Contact(id: "3", nom: "Didi", prenom: "Emile", email: "maurice@test.com"),
            Contact(id: "4", nom: "Toto", prenom: "Gaston", email: "maurice@test.com"),
            Contact(id: "5", nom: "Tete", prenom: "Gaston", email: "maurice@test.com"),
        ]
        }
}

@MainActor
final class NewMessageViewModel: ObservableObject {
    
    @Published private(set) var allContacts: [Contact] = []
    @Published private(set) var filteredContacts: [Contact] = []
    @Published var searchText: String = ""
    let manager = ContactManager()
    private var cancellables = Set<AnyCancellable>()
    
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
            .store(in: &cancellables)
    }

    private func filterContacts(searchText: String) {
        guard !searchText.isEmpty else {
            filteredContacts = []
            return
        }
        
        let search = searchText.lowercased()
        filteredContacts = allContacts.filter({ contact in
            let nomContainsSearch = contact.nom.lowercased().contains(search)
            let prenomContainsSearch = contact.prenom.lowercased().contains(search)
            return nomContainsSearch || prenomContainsSearch
        })
    }
    
    
    
    func loadContacts() async {
        do {
            allContacts = try await manager.getAllContacts()
        } catch  {
            print(error)
        }
    }
}

struct NewMessageView: View {
    
    @StateObject private var viewModel = NewMessageViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.isSearching ? viewModel.filteredContacts : viewModel.allContacts) { contact in
                    ContactCellView(contact: contact)
                }
            }
            .padding()
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Saisir un nom..."))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Contacts")
        .task {
            await viewModel.loadContacts()
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewMessageView()
        }
    }
}
