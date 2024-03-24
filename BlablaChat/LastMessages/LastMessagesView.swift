//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import SwiftUI

// A mettre dans la View
struct LastMessage: Identifiable, Codable {
    let id: String
    let room_id: String
    let room_name: String // nom du créateur du premier message
    let room_date: String
    let message_texte: String
    let message_date: String
    let message_from: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
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
    
    func getLastMessages() async {
        
        Task {
            let AuthUser = try AuthManager.shared.getAuthenticatedUser()
            let user_id = AuthUser.uid
            
            // members contient les rooms avec pour chaque room le dernier message
            self.members = try await LastMessagesManager.shared.getMyRooms(user_id: user_id)

            for member in members {
                print("from: \(member.from_id), to: \(member.to_id), room: \(member.room_id)")
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
                        Text("\(un.room_name)")
                        Text("\(un.room_date)")
                        Text("\(un.message_texte)")
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
