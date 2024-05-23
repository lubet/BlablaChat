//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

// A mettre dans la View
struct LastMessage: Identifiable, Codable, Hashable {
    let id = UUID().uuidString
    let email: String // email du créateur du room
    let message_texte: String
    let message_date: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email = "email"
        case message_texte = "message_texte"
        case message_date = "message_date"
    }
}



@MainActor
class LastMessagesViewModel: ObservableObject {
    
    @Published private(set) var lastMessages: [LastMessage] = []
    @Published private(set) var filteredMessages: [LastMessage] = []
    @Published var searchText: String = ""
    
    private var members: [Member] = []
    
    private var rooms: [Room] = []
    
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
                self?.filterLastMessages(searchText: searchText)
            }
            .store(in: &cancellable)
    }

    private func filterLastMessages(searchText: String) {
        guard !searchText.isEmpty else {
            filteredMessages = []
            return
        }
        
        let search = searchText.lowercased()
        filteredMessages = lastMessages.filter({ message in
            let emailContainsSearch = message.email.lowercased().contains(search)
            let messageContainsSearch = message.message_texte.lowercased().contains(search)
            return emailContainsSearch || messageContainsSearch
        })
    }
    
    func getLastMessages() async {
        
        Task {
            lastMessages = []
            
            let AuthUser = try AuthManager.shared.getAuthenticatedUser()
            let user_id = AuthUser.uid
            
            // Mes room_id dans membre
            self.members = try await LastMessagesManager.shared.getMyRoomsId(user_id: user_id)

            // Tous les rooms avec le dernier message (fait partie de la structure de Room)
            self.rooms = try await LastMessagesManager.shared.getAllRooms()
            
            // Mise en relation de mes member/rooms avec toutes les rooms pour extraire mes derniers messages (contenu dans room)
            for member in members {
                for room in rooms {
                    if member.room_id == room.room_id {
                        lastMessages.append(LastMessage(email: room.room_name, message_texte: room.last_message, message_date: room.date_message))
                    }
                }
                
            }
            
        }
        
    }
    
    func deleteLast(index: IndexSet) {
        lastMessages.remove(atOffsets: index)
    }

}

// -----------------------------------------------------------------------------

struct LastMessagesView: View {
    
    @Binding var showSignInView: Bool
    
    @ObservedObject var viewModel: LastMessagesViewModel = LastMessagesViewModel()
    
    @State var path: [LastMessage] = []
    
    @State var showNewMessageScreen = false // fullSreenCover ContactsView
    
    @State var emailPassed: String = "" // email callback de ContactsView
    
    @State var shouldNavigateToChatLogView = false // call back
    
    var body: some View {
            NavigationStack(path: $path) {
                List {
                    ForEach(viewModel.isSearching ? viewModel.filteredMessages : viewModel.lastMessages) { lastMessage in
                        NavigationLink {
                            MessagesView(path: $path, email: lastMessage.email)
                        } label: {
                            LastMessagesCellView(lastMessage: lastMessage)
                        }
                    }
                }
                NewMessageButton // extension -> MesContactsView() liste des users ancien ou nouveau
                
                    .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Rechercher un correspondant")
                    .task { await viewModel.getLastMessages() }
                    .navigationTitle("LastMessagesView")
                
                // CallBack MessagesView <- email de ContactsView
                    .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                        MessagesView(path: $path, email:emailPassed)
                    }
            }
            .tabItem {
                Text("Messages")
                Label("First", systemImage: "ellipsis.message")
            }
    }
}


// Bouton nouveau contact ------------------
extension LastMessagesView {
    
    private var NewMessageButton: some View {
        Button {
            showNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("Nouveau message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
        
        // FullScreenCover
        .fullScreenCover(isPresented: $showNewMessageScreen) {
            ContactsView(didSelectedNewUser: { emailSelected in
                print(emailSelected) // email callback de l'utilisateur que j'ai selectionné dans ContactsView
                self.emailPassed = emailSelected
                self.shouldNavigateToChatLogView.toggle()
            })
        }
    }
}

struct LastMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesView(showSignInView: .constant(false), emailPassed: "https...")
    }
}
