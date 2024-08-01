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
    func getLastMessages() async {
        Task {
            lastMessages = []
            let AuthUser = try AuthManager.shared.getAuthenticatedUser()
            let user_id = AuthUser.uid
            
            self.rooms = try await LastMessagesManager.shared.getMyRooms(user_id: user_id)
            
            for room in self.rooms {
                lastMessages.append(LastMessage(avatar_link: room.avatar_link ,email: room.room_name, message_texte: room.last_message, message_date: room.date_message))
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
        
        // Recherche de l'avatar
        httpAvatar = try! await UserManager.shared.getAvatar(contact_id: user_id)
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
                            MessagesView(path: $path, email: lastMessage.email) // Détail de la conversation
                        } label: {
                            LastMessagesCellView(lastMessage: lastMessage) // derniers messages envoyés ou reçus
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
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
                
                    .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Rechercher un correspondant")
                
                    .task {
                        await viewModel.getLastMessages() // Les derniers messages
                    }
                    .navigationTitle("LastMessagesView")
                
                // CallBack MessagesView <- email de ContactsView
                    .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                        MessagesView(path: $path, email:emailPassed)
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
