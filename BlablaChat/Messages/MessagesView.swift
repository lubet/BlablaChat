//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//
// Afin de créer un message:
// Voir si il y a un salon entre la personne qui est loggé et une autre personnes (moi et une autre) dans salons-users
// (il faut que les 2 personnes aient le même n° de salon) - Table: salons users
// si il n'y en a pas:
//      créer un salon dans Salons,
//      créer les n personnes avec le même n° de salon dans salons-users
//      créer autant de messages que de personnes dans Messages avec le même n° de salon
// Si un salon existe cad 2 personnes ont le même n° de salon
//     on crée les messages avec ce n° de salon
// peut être étendu à n personnes...
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
        
        // Si le contact n'existe pas dans Users je le crée
        let contactId =  try? await UsersManager.shared.searchContact(email: oneContact.email)
        if contactId == "" {
            let contactId = try await UsersManager.shared.createUser(email: oneContact.email)
        }
        
        guard let contactId else { print("MessagesViewModel: pas de contactId"); return }
        
        // Recherche du salon dans lequel se trouve les deux interlocuteurs (si il y en a un)
        var salonId = await MessagesManager.shared.searchSalon(contactId: contactId, userId: user.userId)
        
        // Pas de salon, j'en crée un dans Salons et je crée deux enregs n°salon,contactI et même n°salon,userId
        if salonId == "" {
            salonId = try await MessagesManager.shared.newSalon()
            try await MessagesManager.shared.newSalonUser(salonId: salonId, contactId: contactId, userId: user.userId)
        }
        
        // Création du message avec le n° de salon et le from égal au userId
        try await MessagesManager.shared.newMessage(salonId: salonId, fromId: user.userId, texte: "Hello")
        
        
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
