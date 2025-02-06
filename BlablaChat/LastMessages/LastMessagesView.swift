//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//
// Liste de derniers messages par room


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

// Dernier Message
struct LastMessage: Identifiable, Codable, Hashable {
    let id = UUID().uuidString
    let avatarLink: String
    let email: String
    let texte: String
    let date: Timestamp
    let salonId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatarLink = "avatar_link"
        case email = "email"
        case texte = "message_texte"
        case date = "message_date"
        case salonId = "salon_id"
    }
}

@MainActor
class LastMessagesViewModel: ObservableObject {
    
    @Published var lastMessages: [LastMessage] = []
    
    init() {
        fetchLastMessages()
    }

    // Derniers messages
    func getLastMessages() async throws {
        Task {
            guard let user = try? UsersManager.shared.getUser() else { return }
            
            // Renvoie tous les salons dont est membre le user
            guard let userMembres = try await LastMessagesManager.shared.userMembres(userId: user.userId) else { return }
            
            for membre in userMembres { // Pour chaque salon
                let salonId = membre.salonId
                // Charger le salon
                guard let salon = try await LastMessagesManager.shared.getSalon(salonId: membre.salonId) else { return }
                let lastMessage = salon.lastMessage
                let contactId = salon.contactId
                
                // avec le contactId du salon récuprer l'email et l'url de l'avatar dans user
                guard let user = try await LastMessagesManager.shared.fetchUser(contactId: contactId) else { return }
                let email = user.email ?? ""
                let urlAvatar = user.avatarLink ?? ""

                lastMessages.append(LastMessage(avatarLink: urlAvatar, email: email, texte: lastMessage, date: Timestamp(), salonId: salonId))
            }
            
        }
    }
    
    func fetchLastMessages() {
        lastMessages.append(LastMessage(avatarLink: "http", email: "Leroy", texte: "Hello1", date: Timestamp(), salonId: "11"))
        lastMessages.append(LastMessage(avatarLink: "http", email: "Gured", texte: "Hello1", date: Timestamp(), salonId: "11"))
        lastMessages.append(LastMessage(avatarLink: "http", email: "Max", texte: "Hello1", date: Timestamp(), salonId: "11"))
    }
    
    func logOut() {
        try? UsersManager.shared.signOut()
        
    }
    
}

// -----------------------------------------------------------------------------

struct LastMessagesView: View {
    
    @ObservedObject var vm: LastMessagesViewModel = LastMessagesViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                VStack {
                    List {
                        ForEach(vm.lastMessages) { message in
                            NavigationLink(value: message) {
                                LastMessagesCellView(lastMessage: message)
                            }
                        }
                    }
                    .navigationTitle("Last messages")
                    .navigationDestination(for: LastMessage.self) { message in
                        ContactsView(salonId: message.salonId)
                    }
                    // .searchable(text: $vm.searchText)
                }
                
                Button("Logout") {
                    vm.logOut()
                    showSignInView = true
                }
            }
        }
    }
}


struct LastMessages_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LastMessagesView(showSignInView: .constant(false))
        }
    }
}
