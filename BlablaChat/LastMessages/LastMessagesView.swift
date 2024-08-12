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
    let avatar_link: String
    let email: String // email du créateur du room
    let message_texte: String
    let message_date: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatar_link = "avatar_link"
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
    @Published var monEmail: String = ""
    @Published var httpAvatar: String = ""
    
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
    
    
    // Mes derniers messages
    // mon room_id m'est donné par members avec mon user_id
    func getLastMessages() async {
        Task {
            lastMessages = []
            let AuthUser = try AuthManager.shared.getAuthenticatedUser()
            let user_id = AuthUser.uid
            
            // Tous mes rooms
            
            // cherher le room_id dans "members" avec le user_id
            let room_id = try await UsersManager.shared.searchRoomId(user_id: user_id)
            
            // Tous mes enregs de "rooms"
            self.rooms = try await LastMessagesManager.shared.getMyRooms(room_id: room_id)
            
            // Balayer les rooms pour l'auth et valorise les messages avec le select_id
            for room in self.rooms {
                
                // Rechercher dans "members" l'enregistrement qui a le même user_id et le même room.room_id -> select_id
                let to_id = try await UsersManager.shared.searchDuo(from_id: user_id, room_id: room.room_id)
                
                // Recherche de l'email dans "users" avec le to_id
                let email = try await UsersManager.shared.searchEmail(user_id: to_id)
                
                lastMessages.append(LastMessage(avatar_link: room.avatar_link, email: email, message_texte: room.last_message, message_date: room.date_message))

                print("user_id: \(user_id)")
            }
        }
    }
    
    func deleteLast(index: IndexSet) {
        lastMessages.remove(atOffsets: index)
    }

    // Entête
    func getMoi() async {
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = authUser.uid
        monEmail = EmailShort(email: authUser.email ?? "")
        
        // Recherche de l'avatar dans users
        httpAvatar = try! await UsersManager.shared.getAvatar(contact_id: user_id)
        // print("\(httpAvatar)")
    }
}

// -----------------------------------------------------------------------------

struct LastMessagesView: View {
    
    @Binding var showSignInView: Bool
    
    @ObservedObject var viewModel: LastMessagesViewModel = LastMessagesViewModel()
    
    @State var path: [LastMessage] = []
    
    @State var showNewMessageScreen = false // fullSreenCover UsersView
    
    @State var emailPassed: String = "" // email callback de UsersView
    
    @State var shouldNavigateToChatLogView = false // call back
    
   // @State var monEmail:String = ""

    
    var body: some View {
            NavigationStack(path: $path) {
                List {
                    ForEach(viewModel.isSearching ? viewModel.filteredMessages : viewModel.lastMessages) { lastMessage in
                        NavigationLink {
                            NewMessagesView(path: $path, email: lastMessage.email) // Détail de la conversation
                        } label: {
                            LastMessagesCellView(lastMessage: lastMessage) // derniers messages envoyés ou reçus
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top,20)
                .onAppear {
                    Task {
                        await viewModel.getMoi() // Pour l'entête
                    }
                }
                
                // Entête
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SDWebImageLoader(url: viewModel.httpAvatar, size: 30)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Text("\(viewModel.monEmail)")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                                SettingsView(showSignInView: $showSignInView)
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                NewMessageButton // -> UsersView
                
                    .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Rechercher un message")
                
                    .task {
                        await viewModel.getLastMessages() // Les derniers messages
                    }
                    .navigationTitle("Derniers messages")
                
                // CallBack MessagesView <- email de ContactsView
                    .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                        NewMessagesView(path: $path, email:emailPassed)
                    }
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
        
        // Callback de UsersView
        .fullScreenCover(isPresented: $showNewMessageScreen) {
            UsersView(didSelectedNewUser: { emailSelected in
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
