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
            ContactModel(nom: "Zorba", prenom: "Robert", email: "alexis@zorba.com")
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
        
        // TODO - A voir...
        // Création d'un auth anonymous pour le contact - quand il se loggera Apple
        // on l'identifiera avec son flag anonymous et son email à trouver
        let authUser = try await AuthManager.shared.signInAnonymous()
        let auth_id = authUser.uid
        
        // Créer le contact dans "Users"
        let user = DBUser(auth: authUser) // userId (pas d'email c'est normal car anonymous)
        try await UsersManager.shared.createDbUser(user: user) // sans l'image
        
        // // Création de l'avatar dans "Storage" et maj de l'image dans "Users"
        try await UsersManager.shared.updateAvatar(userId: auth_id, mimage: mimage)
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
