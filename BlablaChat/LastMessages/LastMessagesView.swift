//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//
// Liste du dernier message des salons du user
// click sur un salon -> tous les messages de ce salon pour ce user + possibilité d'ajouter un message
// click sur nouveau message -> Affichage des users ->  LastMessageView -> tous les messages de ce user


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

// Dernier Message
struct LastMessage: Identifiable, Codable, Hashable {
    let id = UUID().uuidString
    let avatarLink: String
    let emailContact: String
    let texte: String
    let date: Timestamp
    let salonId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatarLink = "avatar_link"
        case emailContact = "email_contact"
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

    // Liste des derniers messages d'un user par salons
    func getLastMessages() async throws {
        Task {
            guard let user = try? UsersManager.shared.getUser() else { return }
            
            // Renvoie tous les salons dont est membre le user
            guard let userMembres = try await LastMessagesManager.shared.userMembres(userId: user.userId) else {
                print("Pas de salons pour le user \(user.userId)")
                return
            }
            
            for membre in userMembres { // Pour chaque salon
                let salonId = membre.salonId
                // Charger le salon
                guard let salon = try await LastMessagesManager.shared.getSalon(salonId: membre.salonId) else {
                    print("Salon inexistant dans Salons: \(membre.salonId)")
                    return
                }
                let lastMessage = salon.lastMessage
                let contactId = salon.contactId
                
                // avec le contactId du salon récuprer l'email et l'url de l'avatar dans user
                guard let contact = try await LastMessagesManager.shared.fetchUser(contactId: contactId) else {
                    print("contactId \(contactId) inexistant dans Users")
                    return
                }
                let emailContact = contact.email ?? ""
                let urlAvatar = user.avatarLink ?? ""

                lastMessages.append(LastMessage(avatarLink: urlAvatar, emailContact: emailContact, texte: lastMessage, date: Timestamp(), salonId: salonId))
            }
            
        }
    }
    
    func fetchLastMessages() {
        lastMessages.append(LastMessage(avatarLink: "http", emailContact: "Leroy", texte: "Hello1", date: Timestamp(), salonId: "11"))
        lastMessages.append(LastMessage(avatarLink: "http", emailContact: "Gured", texte: "Hello1", date: Timestamp(), salonId: "11"))
        lastMessages.append(LastMessage(avatarLink: "http", emailContact: "Max", texte: "Hello1", date: Timestamp(), salonId: "11"))
    }
    
    func logOut() {
        try? UsersManager.shared.signOut()
        
    }
    
}

// -----------------------------------------------------------------------------

struct LastMessagesView: View {
    
    @ObservedObject var vm: LastMessagesViewModel = LastMessagesViewModel()
    
    @Binding var showSignInView: Bool
    
    @State var showUsersView = false // fullSreenCover UsersView
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                VStack {
                    List {
                        ForEach(vm.lastMessages) { message in
                            NavigationLink(value: message.salonId) {
                                LastMessagesCellView(lastMessage: message) // liste des salons/derniers messages du user
                            }
                        }
                    }
                    .navigationTitle("Last messages")
                    .navigationDestination(for: String.self) { salonId in
                        // Tous les messages du salon qui a été selectionné
                        BubblesView(salonId: salonId)
                    }
                    // .searchable(text: $vm.searchText)
                }
                
                // Nouveau message: ContactsView(salonId: message.salonId)
                btnNewMessage

                // Pour les tests:
                Button("Logout") {
                    vm.logOut()
                    showSignInView = true
                }
            }
        }
    }
}


// Bouton Nouveau message ------------------
extension LastMessagesView {
    
    private var btnNewMessage: some View {
        Button {
            showUsersView.toggle()
        } label: {
            HStack {
                Spacer()
                Text("Nouveau destinataire")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                //.shadow(radius: 15)
        }
        
        // Callback de UsersView
        .fullScreenCover(isPresented: $showUsersView) {
            UsersView(didSelectedNewUser: { emailSelected in // Liste des contacts pour un nouveau messages
                self.emailPassed = emailSelected
                self.showChatView.toggle()
            })
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
