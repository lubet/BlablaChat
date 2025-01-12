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
    func getAllMessages(userId: String) {
        
    }

    // Création du message
    func messages(oneContact: ContactModel, userId: String) async throws {
        
        let contact_id =  try? await UsersManager.shared.searchContact(email: oneContact.email)
        if contact_id == "" {
            let contact_id = try await UsersManager.shared.createUser(email: oneContact.email)
        }
        
        // Voir si il y a une conversation entre celui qui est loggé et n personnes (moi et d'autres) dans conversations-personnes
        // (il faut que les n personnes aient le même n° de conversation) - Table: n°conversaton-userId personne
        // si il n'y en a pas:
        //      créer une conversation dans Conversation,
        //      créer les n personnes avec le même n° de conversation dans conversations-personnes
        //      créer autant de messages que de personnes dans Messages avec le même n° de conversation
        // Si un conversation existe cad n personnes ont le même n° de conversation
        //     on crée les messages avec ce n° de conversation
        
        // peut être étendu à n personnes...
        
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
                vm.getAllMessages(userId: user.userId) // user est une globale
                
                // A la créatio du message si le contact est nouveau -> créer dans "Users" en plus et avant de "Messages"
                try await vm.messages(oneContact: oneContact, userId: user.userId)
            }
        }
    }
}

#Preview {
    MessagesView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
