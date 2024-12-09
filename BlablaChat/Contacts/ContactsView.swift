//
//  ContactsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/12/2024.
//

import SwiftUI

@MainActor
class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        contacts = [
            ContactModel(nom: "Leroy", prenom: "Maurice", email: "maurice@leroy.com"),
            ContactModel(nom: "Dugou", prenom: "Robert", email: "robert@dugou.com"),
        ]
    }
    
    // Contact qui a été selectionné dans la liste
    func selectContact(contact: ContactModel) async throws {
        
        let mimage: UIImage = UIImage.init(systemName: "person.fill")!
        
        guard let index = contacts.firstIndex(where: { $0.id == contact.id }) else {
            print("selectContact - Pas d'email")
            return
        }
        
        let contact: ContactModel = contacts[index]
        
        guard !contact.email.isEmpty else {
            print("selectContact - Pas d'email")
            return
        }
        
        // Créer l'auth
        let authUser = try await AuthManager.shared.createUser(email: contact.email, password: "guest2")
        let user_id = authUser.uid
        
        // Créer le contact dans "Users"
        // Création dans "Users"
        let user = DBUser(auth: authUser) // userId, email
        try await UsersManager.shared.createDbUser(user: user) // sans l'image
        
        // // Création de l'avatar dans "Storage" et maj de l'image dans "Users"
        try await UsersManager.shared.updateAvatar(userId: user_id, mimage: mimage)
    }
}


struct ContactsView: View {

    @StateObject var viewModel: ContactsViewModel = ContactsViewModel()
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(viewModel.contacts) { oneContact in
                ContactRowView(oneContact: oneContact)
                    .onTapGesture {
                        Task {
                            try await viewModel.selectContact(contact: oneContact)
                        }
                        presentationMode.wrappedValue.dismiss() // Fermeture de la vue
                    }
            }
        }
        .navigationTitle("Liste")
    }
}

#Preview {
    NavigationView {
        ContactsView()
    }
}
