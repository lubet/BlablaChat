//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

// A mettre dans la View
struct LastMessage: Identifiable, Codable {
    let room_id: String
    let room_name: String // nom du destinataire lors de la création du room
    let room_date: String
    let message_texte: String
    let message_date: Timestamp
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
    
    private var members: [Member] = []
    
    private var rooms: [Room] = []
    
    func getLastMessages() async {
        
        Task {
            let AuthUser = try AuthManager.shared.getAuthenticatedUser()
            let user_id = AuthUser.uid
            
            // Mes room_id dans membre
            self.members = try await LastMessagesManager.shared.getMyRoomsId(user_id: user_id)

            // Tous les rooms avec le dernier message
            self.rooms = try await MessagesManager.shared.getAllRooms()
            
            // Recherche du dernier message dans les rooms à l'aide de mes room_id de member
            for member in members {
                // print("from: \(member.from_id), to: \(member.to_id), room: \(member.room_id)")
                // get le room qui correspond a
                for room in rooms {
                    if member.room_id == room.room_id {
                        lastMessages.append(LastMessage(room_id: member.room_id, room_name: room.room_name,
                        room_date: timeStampToString(dateMessage: room.dateCreated), message_texte: room.last_message, message_date: room.date_message, message_from: room.from_message))
                        print("room_id:\(member.room_id) - room_name:\(room.room_name) - texte:\(room.last_message) - from:\(room.from_message) -  to: \(member.to_id)*****\n")
                        
                    }
                }
                
            }
            
        }
        
    }
    
    func deleteLast(index: IndexSet) async {
        lastMessages.remove(atOffsets: index)
    }

}

struct LastMessagesView: View {
    
    // @ObserverObject relaod si la vue is refresh contrairement à @StateObject
    @ObservedObject var viewModel: LastMessagesViewModel = LastMessagesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.lastMessages) { un in
                    HStack {
                        VStack {
                            Text("\(un.room_name)")
                            Text("\(un.message_texte)")
                        }
                        Text("\(un.room_date)")
                    }
                }
                //.onDelete(perform: viewModel.deleteLast)
            }
            .task { await viewModel.getLastMessages() }
            // .listStyle()
            .navigationTitle("Messages")
            .navigationBarItems(
                leading: Image(systemName: "person.fill"),
                trailing: NavigationLink(
                    destination: monProfil(),
                    label: {Image(systemName: "square.and.pencil")}
                )
            )
        }
    }
}


struct monProfil: View {
    var body: some View {
        Text("Contacts")
    }
}
struct LastMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesView()
    }
}
