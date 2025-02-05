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

    // Dans Membres, ramener tous les salonId auquel appartient le userId
    // Dans Salons, pour chaque salon de Membres, ramener le dernier message texte
    // Dans Users, ramener l'email et l'avatar du user_id
    
    private var tousMesSalons: [Salons] = [] // <- Membres/userId
    
    private var derniersMessages: [Messages] = [] // <- salonId
    
    private var emailAvatars: [DBUser] = [] // <- userId
    
    
    
    init() {
        fetchLastMessages()
    }

    func fetchMyLastMessages() {
        
        // user
        let user = try UsersManager.shared.getUser()
        
        tousMesSalons = 
        
        
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
