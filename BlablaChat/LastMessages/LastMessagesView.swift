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
struct LastMessage: Identifiable, Codable {
    let room_id: String
    let room_name: String // nom du destinataire lors de la création du room
    let room_date: String
    let message_texte: String
    let message_date: String
    let message_from: String
    
    var id: String {
        room_id
    }

    enum CodingKeys: String, CodingKey {
        case room_id = "room_id"
        case room_name = "room_name"
        case room_date = "room_date"
        case message_texte = "messge_texte"
        case message_date = "message_date"
        case message_from = "message_from"
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
            let emailContainsSearch = message.room_name.lowercased().contains(search)
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
                        lastMessages.append(LastMessage(room_id: member.room_id, room_name: room.room_name,
                                                        room_date: timeStampToString(dateMessage: room.dateCreated), message_texte: room.last_message,
                                                        message_date: timeStampToString(dateMessage:  room.date_message), message_from: room.from_message))
                        print("room_id:\(member.room_id) - room_name:\(room.room_name) - texte:\(room.last_message) - from:\(room.from_message) -  to: \(member.to_id)*****\n")
                        
                    }
                }
                
            }
            
        }
        
    }
    
    func deleteLast(index: IndexSet) {
        lastMessages.remove(atOffsets: index)
    }

}

struct LastMessagesView: View {
    
    // @ObserverObject relaod si la vue is refresh contrairement à @StateObject
    @ObservedObject var viewModel: LastMessagesViewModel = LastMessagesViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.isSearching ? viewModel.filteredMessages : viewModel.lastMessages) { lastMessage in
                    NavigationLink(value: lastMessage.room_id) {
                        LastMessagesCellView(lastMessage: lastMessage)
                    }
                }
                .onDelete(perform: viewModel.deleteLast)
            }
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: "Rechercher un correspondant")
            .task { await viewModel.getLastMessages() }
            // .listStyle()
            .navigationTitle("Messages")
            .navigationDestination(for: String.self) { value in
                RoomMessagesView(value: value)
            }
            .navigationBarItems(
                leading: Image(systemName: "person.fill"),
                trailing: NavigationLink(
                    destination: NewContactView(),
                    label: {Image(systemName: "square.and.pencil")}
                )
            )
        }
    }
}

struct LastMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesView()
    }
}
