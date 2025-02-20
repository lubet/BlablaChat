//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//
// Liste du dernier message des salons du user
// click sur un salon -> tous les messages de ce salon pour ce user + possibilité d'ajouter un message
// click sur nouveau message -> Affichage des users ->  LastMessageView -> tous les messages de ce user
//
// TODO: Cas d'un nouveau contact
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class LastMessagesViewModel: ObservableObject {
    
    @Published private(set) var lastMessages: [LastMessage] = []
    
    @Published private(set) var userEmail: String = ""
    @Published private(set) var userAvatarLink: String = ""

    // Liste des derniers messages d'un user par salons
    func getLastMessages() async {

        Task {
            
            lastMessages = []
            
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
                // print("lastMessages:\(lastMessages)")
            }
            
        }
    }
    
    func logOut() {
        try? UsersManager.shared.signOut()
    }
    
    func getUserAvatarLink() {
        guard let user = try? UsersManager.shared.getUser() else { return }
        userEmail = user.email ?? ""
        userAvatarLink = user.avatarLink ?? ""
    }
}

// -----------------------------------------------------------------------------

struct LastMessagesView: View {
    
    @ObservedObject var vm: LastMessagesViewModel = LastMessagesViewModel()
    
    @Binding var showSignInView: Bool
    
    @State var showUsersView = false // fullSreenCover UsersView (contacts)
    
    @State var emailPassed: String = "" // email callback de UsersView
    
    @State var showChatView = false // -> ChatView avec call back ->
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            NavigationStack {
                    List {
                        ForEach(vm.lastMessages) { message in
                            NavigationLink {
                                BubblesView(emailContact: message.emailContact)
                            } label: {
                                LastMessagesCellView(lastMessage: message)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            SDWebImageLoader(url: vm.userAvatarLink, size: 30)
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Text("\(vm.userEmail)")
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink {
                                SettingsView(showSignInView: $showSignInView)
                            } label: {
                                Image(systemName: "gear")
                            }
                        }
                    }

                    btnNewMessage // -> ContactsView

                    .navigationTitle("Last messages")
                
                    .task {
                        await vm.getLastMessages() // Les derniers messages
                    }
                
                    // -> Bubbles en retour des contacts
                    .navigationDestination(isPresented: $showChatView) {
                        BubblesView(emailContact: emailPassed)
                    }

                
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
        
        // -> Contacts
        .fullScreenCover(isPresented: $showUsersView) {
            ContactsView(didSelectedNewUser: { emailSelected in // Liste des contacts pour un nouveau messages
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
