//
//  SwiftUIView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/01/2024.
//
// Liste des users compris les nuveaux contacts
//
// Choisir un contact, saisir un message et l'envoyer
// 1) Vérifier si le contact choisit est présent dans "users"
//       si il ne l'est pas -> le creer et prendre son user_id qui devient le contact_id)
//       si il y est -> prendre son user-id
// 2) Chercher dans "group_member" si il existe un enreg avec mon user_id et le contact_id ayant le même room_id (conversation)
//      si oui: une conversation existe déjà -> 3)
//      si non -> créer un enreg dans room (nouvelle conversation)
//                créer un enreg dans membre (mon user_id, contact_id, room-id. (nouveau membre: moi et le contact).
// 3) Créer le message avec le room_id
// ---------------------------------------------------------------------------------------------------------------------------

import SwiftUI
import Combine

@MainActor
final class MesContactsViewModel: ObservableObject {
    
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
        print("MesContactsViewModel - getContacts")
    }

    // Sauvegarde message "texte" avec avatar "personne" pour les nouveaux contacts
    func saveMessage(to_email: String, textMessage: String) async throws {
        // mon user_id
        let AuthUser = try AuthManager.shared.getAuthenticatedUser()
        let user_id = AuthUser.uid
        print("user_id:\(user_id)")
        
        // user_id d'un contact
        var contact_id: String = ""
        
         let contactId = try await ContactsManager.shared.searchContact(email: to_email) // Recherche du contact_id dans "users"
        
        print("contactId?:\(contactId)")
        
        if contactId != "" {
            contact_id = contactId
            print("createContact trouvé:\(contactId)") // Ancien contact
        } else {
            contact_id = try await ContactsManager.shared.createUser(email: to_email) // Nouveau contact
            print("createContact retour:\(contact_id)")
        }
        
        // TODO Virer le chien et mettre une image si existante
        print("Avant url")
        guard let url = URL(string: "https://picsum.photos/id/237/200/300") else { return }
        print("Après url")
        
        // Renvoie le room_id du couple from/to ou to/from présent ou non dans membre
        let room = try await ContactsManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
        if (room == "") {
            // Non -> créer un room
            let room_id = try await ContactsManager.shared.createRoom(name: to_email)
            // création d'un document membre
            try await ContactsManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: contact_id)
            // Créer un message avec le room
            try await ContactsManager.shared.createMessage(from_id: user_id, to_id: contact_id, message_text: textMessage, room_id: room_id, image_link: url.absoluteString)
        } else {
            // Si un room commun -> créer le message avec le room existant
            try await ContactsManager.shared.createMessage(from_id: user_id, to_id: contact_id, message_text: textMessage, room_id: room, image_link: url.absoluteString)
        }
    }
}

// --------------------------------------------------

struct MesContactsView: View {
    
    @StateObject var viewModel = MesContactsViewModel()
    
    @State private var searchText: String = ""
    
    @State private var messageTexte: String = ""
    
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.isSearching ? viewModel.filteredContacts : viewModel.mesContacts, id: \.self) { oneContact in
                    NavigationLink(value: oneContact) {
                        // ContactCellView(lecontact: oneContact)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Rechercher un contact")
            
            .task { await viewModel.getContacts() }
            
            .navigationTitle("MesContactsView")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .navigationDestination(for: Contact.self) {
                value in
                Essai4View(email: value.email)
            }
        }
    }
}

struct MesContactsView_Previews: PreviewProvider {
    static var previews: some View {
        MesContactsView()
    }
}

