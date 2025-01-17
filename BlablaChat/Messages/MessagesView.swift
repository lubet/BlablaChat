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
//      créer les 2 personnes avec le même n° de salon dans salons-users
//      créer le message dans Messages avec le même n° de salon et le from = userId
// Si un salon existe cad 2 personnes ont le même n° de salon
//     on crée le message avec ce n° de salon
// (peut être étendu à n personnes... à voir plus tard)
//
// 1) Si c'est un nouveau contact (email non existant dans "Users" -> création dans "Users" (nouveau userId)
// forcemment je n'ai pas de salon -> création d'un salon et de deux enregs salons-users avec le même n° de salon.
// Création du message ave le n° de salon et fromId = userId
// Liste des messages du user_id courant
//

import SwiftUI

@MainActor
final class MessagesViewModel: ObservableObject {
    
    @Published var allMessages: [Messages] = []
    
    // Messages du user
    func getMessages() async throws {
        let user = try UsersManager.shared.getUser()
        allMessages = try await MessagesManager.shared.getMessages(userId: user.userId)
    }

    // Création du message
    func newMessages(oneContact: ContactModel, texteMessage: String) async throws {
        let user = try UsersManager.shared.getUser()
        
        // Recherche du contact dans la base "Users"
        var contactId =  try? await UsersManager.shared.searchContact(email: oneContact.email)
        
        // Création dans "Users" si pas présent
        if contactId == "" {
            contactId = try await UsersManager.shared.createUser(email: oneContact.email)
        }
        
        guard let contactId else { print("MessagesViewModel: pas de contactId"); return }
        
        // Recherche do salonId commun au contact et au user
        var salonId = try await MessagesManager.shared.searchSalonsUsers(contactId: contactId, userId: user.userId)
        
        // Pas de salonsId
        if salonId == "" {
            salonId = try await MessagesManager.shared.newSalon() // Création d'un salon
            
            // Création contact et user même salon dans Salons-Users
            try await MessagesManager.shared.newSalonsUsers(salonId: salonId, contactId: contactId, userId: user.userId)
        }
        
        // Création du message avec le n° de salon et le fromId égal au user
        try await MessagesManager.shared.newMessage(salonId: salonId, fromId: user.userId, texte: texteMessage)
    }
}

struct MessagesView: View {
    let oneContact: ContactModel // <- ContactsView
    
    @StateObject var vm = MessagesViewModel()
    
    @State private var texteMessage: String = ""
    
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false

    var body: some View {
        List {
            ForEach(vm.allMessages) { message in
                Text("\(message)")
            }
        }
        .onAppear {
            Task {
                try await vm.getMessages()
            }
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
    }
}

// Barre de saisie et d'envoie du message
extension MessagesView {
    
    private var MessageBar: some View {
        HStack {
            // Selection de la photo
//            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
//                Image(systemName: "photo")
//                    //.foregroundColor(Color.black)
//            }
            
            // Saisie du message
            TextField("Message", text: $texteMessage, axis: .vertical)
                .disableAutocorrection(true)
            
            // Envoi du message
            Image(systemName: "paperplane.circle")
                .padding()
                .offset(x:10)
                .foregroundColor(Color.blue)
                .opacity(texteMessage.isEmpty ? 0.0 : 1.0)
                .onTapGesture {
                    sendButton()
                }
        }
        .font(.headline)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.05))
        )
        .padding()
    }
    
    // Sauvegarde du message "texte"
    func sendButton() {
        if textIsCorrect() {
            // path.removeAll() // back to LastMessagesView
            Task {
                try? await vm.newMessages(oneContact: oneContact, texteMessage: texteMessage)
                texteMessage = ""
            }
        }
    }
    
    func textIsCorrect() -> Bool {
        if texteMessage.count < 3 {
            alertTitle = "Saisir un message d'au moins 3 caractères"
            showAlert.toggle()
            return false
        }
        return true
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle))
    }

}


#Preview {
    MessagesView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
