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
    
    func messages(oneContact: ContactModel) async throws {
        
        // Si le contact est nouveau - avec l'email recherche dans la base "Users"
        let new =  try? await UsersManager.shared.searchContact(email: oneContact.email)
        
        // le créer dans "Users"
        
        // créer le message
        
        // charger tous les messages du user_id courant
        
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
                try await vm.messages(oneContact: oneContact)
            }
        }
    }
}

#Preview {
    MessagesView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
