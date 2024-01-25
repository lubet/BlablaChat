//
//  SearchableBootcampView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/01/2024.
//

import SwiftUI
import Combine

struct Contact: Identifiable {
    let id: String
    let title: String
    let nom: String
}

final class ContactManager {
    
    func getAllContacts() async throws -> [Contact] {
        [
            Contact(id: "1", title: "Burger Shack", nom: "american"),
            Contact(id: "2", title: "Pasta Palace", nom: "italian"),
            Contact(id: "3", title: "Sushi Heaven", nom: "japanese"),
            Contact(id: "4", title: "Local Market", nom: "american"),
        ]
    }
}

@MainActor
final class NewMessageViewModel: ObservableObject {
    
    @Published private(set) var allContacts: [Contact] = []
    @Published var searchText: String = ""
    
    let manager = ContactManager()
    
    func loadContacts() async {
        do {
            allContacts = try await manager.getAllContacts()
        } catch {
            print(error)
        }
    }
}

struct NewMessageView: View {
    
    @StateObject private var viewModel = NewMessageViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.allContacts) { contact in
                    contactRow(contact: contact)
                }
            }
            .padding()
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Recherche d'un contact"))
        .navigationTitle("Contacts")
        .task {
            await viewModel.loadContacts()
        }
    }
    
    private func contactRow(contact: Contact) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(contact.title)
                .font(.headline)
                .foregroundColor(.red)
            Text(contact.nom.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .tint(.primary)
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewMessageView()
        }
    }
}
