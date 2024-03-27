//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 11/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessageItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    let room_id: String
    let room_name: String
    let room_date: Timestamp
    let from_id: String
    let received: Bool
    let message_text: String
    let message_send: Timestamp
}

@MainActor
final class MessagesViewModel: ObservableObject {
    
    var messages: [Message] = []

    var rooms: [Room] = []
    
    @Published private(set) var messageItems: [MessageItem] = []
    
    // Affichage des messages
    func fetchLastMessages() async {
        
        Task {
            
            messageItems = []
            
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let user_id = authDataResult.uid
            
            // All mes messages send or received
            self.messages = try await MessagesManager.shared.getMessages(user_id: user_id)
            
            // All rooms
            self.rooms = try await MessagesManager.shared.getAllRooms()
            
            // Affichage de messageItems avec infos rooms
            var received: Bool = false
            for room in rooms {
                for message in messages {
                    if (message.room_id == room.room_id) {
                        received = false
                        if (message.from_id == user_id) {
                            received = true
                        }
                        messageItems.append(contentsOf: [MessageItem(room_id: message.room_id, room_name: room.room_name, room_date: room.dateCreated, from_id: message.from_id, received: received, message_text: message.message_text, message_send: message.date_send)])
                    }
                }
            }
        }
    }
}


struct MessagesView: View {
    
    @StateObject private var viewModel = MessagesViewModel()
    
    var body: some View {
            List {
                VStack {
                    ForEach(viewModel.messageItems) { oneMessage in
                        MessageCellView(messageItem: oneMessage)
                    }
                }
            }
            .task { await viewModel.fetchLastMessages() }
            .navigationTitle("Conversations")
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
