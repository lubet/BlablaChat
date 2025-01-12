//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//
// 1) Si c'est un nouveau (email non existant dans "Users" -> création dans "Users" (nouveau user_id) -> création dans "Messages"
// Liste des messages du user_id courant
//

import SwiftUI

@MainActor
final class MessagesViewModel: ObservableObject {
    
    @Published var allMessages: [Messages] = []
    
    //getAllmessages du user_id courant
    func getAllMessages(user_id: String) {
        
    }

    // Création du message
    func messages(oneContact: ContactModel) async throws {
        
        // Si le contact est nouveau - avec l'email recherche dans la base "Users"
        let user_id =  try? await UsersManager.shared.searchContact(email: oneContact.email)
        
        // le créer dans "Users"
        if user_id == "" {
            let user_id = try await UsersManager.shared.createUser(email: oneContact.email)
        }
        
        // Créer le message
        
        
    }
}

struct MessagesView: View {
    
    let oneContact: ContactModel
    
    @StateObject var vm = MessagesViewModel()
    
    var body: some View {
        List {
            
        }
        .onAppear {
            Task {
                // Lister tous les messages du user_id courant
                vm.getAllMessages(user_id: user.userId) // user est une globale
                
                // A la créatio du message si le contact est nouveau -> créer dans "Users" en plus et avant de "Messages"
                try await vm.messages(oneContact: oneContact)
            }
        }
    }
}

#Preview {
    MessagesView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
