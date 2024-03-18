//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 11/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class MessagesViewModel: ObservableObject {
    
    var messages: [Message] = []

    var rooms: [Room] = []
    
    @Published private(set) var messageItems: [MessageItem] = []
    
    func fetchLastMessages() async {
        
        print("fetchLastMessages")
        
        Task {
            
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let user_id = authDataResult.uid
            
            // Mes messages send or received
            self.messages = try await MessagesManager.shared.getMessages(user_id: user_id)
            
            // All rooms
            self.rooms = try await MessagesManager.shared.getAllRooms()
            
            // Merge messages with infos rooms
            // self.messageItems = try await MessagesManager.shared.majMessages(messages: messages, rooms: rooms)
            
            for room in rooms {
                for message in messages {
                    if message.room_id == room.room_id {
                        messageItems = [MessageItem(room_id: message.room_id, room_name: room.room_name, room_date: room.dateCreated, from_id: message.from_id, to_id: message.to_id, message_text: message.message_text, message_send: message.date_send)]
                        print("messageItems: \(messageItems)\n")
                    }
                }
            }
        }
    }
}


struct MessagesView: View {
    
    @StateObject private var viewModel = MessagesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
//                    ForEach(viewModel.messages) { oneMessage in
//                        // Text(oneContact.nom)
//                        MessageCellView(messageItem: oneMessage)
//                    }
                }
            }
        }
        .task { await viewModel.fetchLastMessages() }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
