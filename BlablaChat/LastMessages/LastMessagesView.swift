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
    

    // Liste des derniers messages d'un user par salons
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
            
            // Renvoie tous les salons Ids ddu currentUser
            guard let userSalonsIds = try await LastMessagesManager.shared.userSalons(userId: currentUserId) else {
                return
            }
            
            for userSalonId in userSalonsIds {
                // Infos du salon
                guard let salon = try await LastMessagesManager.shared.getSalon(salonId: userSalonId) else {
                    print("**** getLastMessages() salon"); return }
                print("salon \(userSalonId)")
                
                let lastMessage = salon.lastMessage
                
                let contactId = salon.contactId
                let userId = salon.userId
                
                var email: String = ""
                var avatarLink: String = ""
                
                if contactId == currentUserId {
                    // prendre le userId
                    guard let user = try await UsersManager.shared.searchUser(userId: salon.userId) else {
                        print("**** getLastMessages() userSalon"); return }
                    email = user.email ?? "inconnu"
                    avatarLink = user.avatarLink ?? "inconnu"
                    print("email user: \(email)")

                } else {
                    // prendre le contactId
                    guard let contact = try await UsersManager.shared.searchUser(userId: salon.contactId) else {
                        print("**** getLastMessages() userSalon"); return }
                    email = contact.email ?? "inconnu"
                    avatarLink = contact.avatarLink  ?? "inconnu"
                    print("email contact: \(email)")
                }
                
                // TODO c'est l'email de l'envoyeur que l'on devrait trouver ici
                lastMessages.append(LastMessage(avatarLink: avatarLink, emailContact: email, texte: lastMessage, date: Timestamp(), salonId: userSalonId))
            }
        }
    }
    
    func logOut() {
        try? UsersManager.shared.signOut()
    }
    
    func getUserToolBar() {
        
//        userEmail = user.email ?? ""
//        userAvatarLink = user.avatarLink ?? ""
        
        // print("**** getUserToolBar()")
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
                    .background(Color.theme.buttoncolor)
//                    .onAppear {
//                        Task {
//                            vm.getUserToolBar() // AvatarLink et email du user
//                        }
//                    }
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

                    .navigationTitle("Derniers messages")
                
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
            .foregroundColor(Color.theme.buttontext)
            .padding(.vertical)
            .background(Color.theme.buttoncolor)
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
            Group {
                LastMessagesView(showSignInView: .constant(false))
                    .preferredColorScheme(.light)
                LastMessagesView(showSignInView: .constant(false))
                    .preferredColorScheme(.dark)
        }
    }
}
