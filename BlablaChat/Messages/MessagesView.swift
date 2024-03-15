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
            self.messageItems = try await MessagesManager.shared.majMessages(messages: messages, rooms: rooms)
            
            
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
