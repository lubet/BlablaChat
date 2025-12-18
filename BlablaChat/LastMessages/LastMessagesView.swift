//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//
// Le dernier message de chaque salon du user en cours
// avec le nom du destinataire du dernier message, son email et le dernier message
//


import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class LastMessagesViewModel: ObservableObject {

    @AppStorage("currentUserId") var currentUserId: String?
    
    @Published private(set) var lastMessages: [LastMessage] = []
    
    @Published private(set) var userEmail: String = ""
    @Published private(set) var userAvatarLink: String = ""
    @Published private(set) var userNom: String = ""
    @Published private(set) var userPrenom: String = ""

    // Liste des derniers messages du currentuser par salon 
    func getLastMessages() async {
        print("**** LastMessagesView-getLastMessages()")
        Task {
            
            lastMessages = []
            
            // @AppStorage
            guard let currentUserId = currentUserId else { print("**** getLastMessages()-currentUserId = nil") ; return }
            
            // Infos du currentUser
            guard let dbuser = try await UsersManager.shared.searchUser(userId: currentUserId) else { return }
                userEmail = dbuser.email ?? "**** Inconnu"
                userAvatarLink = dbuser.avatarLink ?? "**** Inconnu"
                userNom = dbuser.nom
                userPrenom = dbuser.prenom
            
            // Les salons du currentuser
            guard let userSalonsIds = try await LastMessagesManager.shared.userSalons(userId: currentUserId) else {
                return
            }
            
            
            
            print("userSalonsIds: \(userSalonsIds)")
            
            // Pour chaque salon où le currentuser est présent
            for userSalonId in userSalonsIds {
                // Infos du salon
                guard let salon = try await LastMessagesManager.shared.getSalon(salonId: userSalonId) else {
                    print("**** getLastMessages() salon"); return }
                
                print("userSalonId: \(userSalonId)")
                
                let lastMessage = salon.lastMessage
                
                let contactId = salon.sendTo
                
                var email: String = ""
                var avatarLink: String = ""
                var nom: String = ""
                var prenom: String = ""
                
                if contactId == currentUserId {
                    // prendre le userId
                    guard let user = try await UsersManager.shared.searchUser(userId: salon.sendTo) else {
                        print("**** getLastMessages() userSalon1"); return }
                    email = user.email ?? "inconnu"
                    avatarLink = user.avatarLink ?? "inconnu"
                    nom = user.nom
                    prenom = user.prenom
                } else {
                    // prendre le contactId
                    guard let contact = try await UsersManager.shared.searchUser(userId: salon.sendTo) else {
                        print("**** getLastMessages() userSalon2"); return }
                    email = contact.email ?? "inconnu"
                    avatarLink = contact.avatarLink  ?? "inconnu"
                    nom = contact.nom
                    prenom = contact.prenom
                }
                
                // TODO c'est l'email de l'envoyeur que l'on devrait trouver ici
                lastMessages.append(LastMessage(avatarLink: avatarLink, emailContact: email, texte: lastMessage, date: Timestamp(), salonId: userSalonId, nom: nom, prenom: prenom))
            }
        }
    }
    
    func logOut() {
        try? UsersManager.shared.signOut()
    }
}

struct LastMessagesView: View {
    
    @Environment(\.router) var router
    
    @ObservedObject var vm: LastMessagesViewModel = LastMessagesViewModel()
    
    @State var showContactsView = false // fullSreenCover ContactsView (contacts)
    
    var body: some View {
        ZStack {
            Color.theme.background.edgesIgnoringSafeArea(.all)
            VStack {
                List {
                    ForEach(vm.lastMessages) { message in
                        LastMessagesCellView(lastMessage: message)
                            .onTapGesture {
                                Task {
                                    let contact:ContactModel = ContactModel(nom: message.nom, prenom: message.prenom, email: message.emailContact)
                                    router.showScreen(.push) { _ in
                                        BubblesView(oneContact: contact)
                                    }
                                }
                            }
                    }
                }
                .navigationTitle("Messages")
                
                .toolbar {
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            //
                        }, label: {
                            SDWebImageLoader(url: vm.userAvatarLink, size: 30)
                        })
                    }
                    .sharedBackgroundVisibility(.hidden)
                    
                    ToolbarSpacer(.fixed, placement: .topBarLeading)
                    
                    ToolbarItem(placement: .principal) {
                        Text("      \(vm.userNom)") }
                    .sharedBackgroundVisibility(.hidden)
                    
                    // Trailing -----------------------------------------------
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Contacts", systemImage: "person.3.sequence.fill") {
                            router.showScreen(.push) { _ in
                                ContactsView()
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                    .sharedBackgroundVisibility(.hidden)
                    
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Image(systemName: "gear")
                            .onTapGesture {
                                router.showScreen(.push) { _ in
                                    SettingsView()
                                }
                            }
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
                
                Spacer()
                
                btnLogout
            }
            .task {
                await vm.getLastMessages()
            }
        }
    }
}

// Bouton Nouveau message ------------------------------------
extension LastMessagesView {
    private var btnLogout: some View {
        Button {
            vm.logOut()
        } label: {
            Text("Se déconnecter".uppercased())
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .padding(.horizontal, 40)
                .background(Color.theme.buttoncolor)
                .cornerRadius(20)
        }
    }
}

#Preview {
    LastMessagesView()
}
