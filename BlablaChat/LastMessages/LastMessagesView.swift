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
        Task {
            lastMessages = []
            
            // @AppStorage
            guard let currentUserId = currentUserId else { print("**** getLastMessages()-currentUserId = nil") ; return }
            
            // Infos du currentUser
            guard let currentUser = try await UsersManager.shared.searchUser(userId: currentUserId) else { return }
            userEmail = currentUser.email ?? "**** Inconnu"
            userAvatarLink = currentUser.avatarLink ?? "**** Inconnu"
            userNom = currentUser.nom
            userPrenom = currentUser.prenom

            // Les salons du currentUser
            guard let salonsCurrent = try await LastMessagesManager.shared.getSalonsCurrent(currentUserId: currentUserId) else { print("getLastMessages-salonsCurrent = nil"); return }

            var email: String = ""
            var avatarLink: String = ""
            var nom: String = ""
            var prenom: String = ""
            
            // Dernier messsage de chaque salon
            for salon in salonsCurrent {
                let lastMessage = salon.lastMessage
                let senderId = salon.sender
                
                guard let sender = try await UsersManager.shared.searchUser(userId: senderId) else { continue }
                email = sender.email ?? "**** Inconnu"
                avatarLink = sender.avatarLink ?? "**** Inconnu"
                nom = sender.nom
                prenom = sender.prenom

                lastMessages.append(LastMessage(avatarLink: avatarLink, emailContact: email, texte: lastMessage, date: Timestamp(), salonId: salon.salonId, nom: nom, prenom: prenom))
                
            }
        }
    }
    
    func logOut() {
        try? UsersManager.shared.signOut()
    }
}

struct LastMessagesView: View {
    
    @Environment(\.router) var router
    
    @StateObject var vm: LastMessagesViewModel = LastMessagesViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.background.edgesIgnoringSafeArea(.all)
            VStack {
                List(vm.lastMessages) { message in
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
