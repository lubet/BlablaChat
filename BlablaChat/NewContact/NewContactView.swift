//
//  SwiftUIView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/01/2024.
//
// Choisir un contact, saisir un message et l'envoyer
// 1) Vérifier si le contact choisit est présent dans "users"
//       si il ne l'est pas -> le creer et prendre son user_id
//       si il y est -> prendre son user-id
// 2) Chercher dans "group_member" si il existe les deux user_id
//      avec le même conversation_id
//      si oui -> 3)
//      si non -> créer 2 enregs:
//          mon_user_id + conversation_id
//          destinataire_user_id + même conversation_id
// 3) Créer le message avec le conversation_id
// -----------------------------------------------------

import SwiftUI

@MainActor
final class NewContactViewModel: ObservableObject {
    
    // init() { }
    
    @Published private(set) var mesContacts: [Contact] = []
    private(set) var pairMembres: [Member] = []

    func getContacts() async {
            // self.mesContacts = await ContactManager.shared.getAllContacts()
        self.mesContacts = await ContactManager.shared.mockContacts()
    }

    func saveMessage(to_email: String, textMessage: String) async throws {
        // mon user_id
        let AuthUser = try AuthManager.shared.getAuthenticatedUser()
        let user_id = AuthUser.uid
        // Le contact_id
        let contact_id:String = ""
        
        let dbUser = try await NewContactManager.shared.searchContact(email: to_email)
        // Le contact existe il dans "users"
        if let email = dbUser.email { // oui
            let contact_id = dbUser.userId
        } else {
            // non
            let contact_id = try await NewContactManager.shared.createContact(email: to_email)
        }
        
        // Le triptique user_id et contact_id avec le même conversation id existe t'il dans dans "group_member"
        let conversation = try await NewContactManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
        
        if (conversation != "") {
            // Il y a une conversation commune -> créer un message avec la conversation
        } else {
            // Il n'y a pas de conversation commune -> créer une nouvelle conversation et céer un massage avec cette conversation
        }
        
        
    }
}

struct NewContactView: View {
    
    @StateObject var viewModel = NewContactViewModel()
    
    @State private var searchText: String = ""
    
    @State private var messageTexte: String = ""
    
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    var filteredContacts: [Contact] {
        guard !searchText.isEmpty else { return viewModel.mesContacts}
        return viewModel.mesContacts.filter { $0.nom.localizedCaseInsensitiveContains(searchText)}
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(filteredContacts) { oneContact in
                        // Text(oneContact.nom)
                        ContactCellView(lecontact: oneContact)
                    }
                }
            }
            bottomMessageBar
            .navigationTitle("Contacts")
            .alert(isPresented: $showAlert) {
                getAlert()
            }
        }
        .task { await viewModel.getContacts() }
        .searchable(text: $searchText, prompt: "Recherche d'un contact")
    }
}


struct NewContactView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactView()
    }
}

// Barre de saisie et d'envoie du message
extension NewContactView {
    
    private var bottomMessageBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                TextEditor(text: $messageTexte)
                    .opacity(messageTexte.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                    sendButtonPresses()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    func sendButtonPresses() {
        if textIsCorrect() {
            Task {
                try? await viewModel.saveMessage(to_email: filteredContacts[0].email, textMessage: messageTexte)
            }
        }
    }
    
    func textIsCorrect() -> Bool {
        if messageTexte.count < 3 {
            alertTitle = "Saisir un message d'au moins 3 caractères"
            showAlert.toggle()
            return false
        }
        if filteredContacts.count != 1 {
            alertTitle = "Veuillez selectionner un contact"
            showAlert.toggle()
            return false
        }
        return true
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle))
    }
}