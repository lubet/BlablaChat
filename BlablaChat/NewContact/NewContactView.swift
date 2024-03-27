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
import Combine

@MainActor
final class NewContactViewModel: ObservableObject {
    
    @Published private(set) var mesContacts: [Contact] = []
    @Published private(set) var filteredContacts: [Contact] = []
    @Published var searchText: String = ""
    
    private var cancellable = Set<AnyCancellable>()

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
            .store(in: &cancellable)
    }

    private func filterContacts(searchText: String) {
        guard !searchText.isEmpty else {
            filteredContacts = []
            return
        }
        
        let search = searchText.lowercased()
        filteredContacts = mesContacts.filter({ contact in
            let emailContainsSearch = contact.nom.lowercased().contains(search)
            let messageContainsSearch = contact.email.lowercased().contains(search)
            return emailContainsSearch || messageContainsSearch
        })
    }
    
    func getContacts() async {
        self.mesContacts = await ContactManager.shared.mockContacts()
    }

    func saveMessage(to_email: String, textMessage: String) async throws {
        // mon user_id
        let AuthUser = try AuthManager.shared.getAuthenticatedUser()
        let user_id = AuthUser.uid
        print("user_id:\(user_id)")
        
        // user_id d'un contact
        var contact_id: String = ""
        
         let contactId = try await NewContactManager.shared.searchContact(email: to_email) // Recherche du contact_id dans "users"
        
        print("contactId?:\(contactId)")
        
        if contactId != "" {
            contact_id = contactId
            print("createContact trouvé:\(contactId)") // contact existant dans "users"
        } else {
            contact_id = try await NewContactManager.shared.createUser(email: to_email) // Création du contact dans "users"
            print("createContact retour:\(contact_id)")
        }
        
        // Renvoie le room_id du couple from/to ou to/from présent ou non dans membre
        let room = try await NewContactManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
        if (room == "") {
            // Non -> créer un room
            let room_id = try await NewContactManager.shared.createRoom(name: to_email)
            // création d'un document membre
            try await NewContactManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: contact_id)
            // Créer un message avec le room
            try await NewContactManager.shared.createMessage(from_id: user_id, to_id: contact_id, message_text: textMessage, room_id: room_id)
        } else {
            // Si un room commun -> créer le message avec le room existant
            try await NewContactManager.shared.createMessage(from_id: user_id, to_id: contact_id, message_text: textMessage, room_id: room)
        }
    }
}

struct NewContactView: View {
    
    @StateObject var viewModel = NewContactViewModel()
    
    @State private var searchText: String = ""
    
    @State private var messageTexte: String = ""
    
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    var body: some View {
        List {
            VStack {
                ForEach(viewModel.isSearching ? viewModel.filteredContacts : viewModel.mesContacts) { oneContact in
                    ContactCellView(lecontact: oneContact)
                }
            }
        }
        .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Rechercher un contact")
        bottomMessageBar
            .navigationTitle("Contacts")
            .alert(isPresented: $showAlert) {
                getAlert()
            }
            .task { await viewModel.getContacts() }
            // .searchable(text: $searchText, prompt: "Recherche d'un contact")
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
                try? await viewModel.saveMessage(to_email: viewModel.filteredContacts[0].email, textMessage: messageTexte)
            }
        }
    }
    
    func textIsCorrect() -> Bool {
        if messageTexte.count < 3 {
            alertTitle = "Saisir un message d'au moins 3 caractères"
            showAlert.toggle()
            return false
        }
        if viewModel.filteredContacts.count != 1 {
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
