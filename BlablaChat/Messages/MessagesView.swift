//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class MessagesViewModel: ObservableObject {
    
    @Published private(set) var messagesBubble: [MessageBubble] = []
    
    func getRoomMessages(room_id: String) async throws {
        
        let AuthUser = try AuthManager.shared.getAuthenticatedUser()
        let user_id = AuthUser.uid
        
        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: user_id)
        // print("RoomMessages: \(RoomMessages)")
    }
}

struct MessagesView: View {
    
    @StateObject private var viewModel = MessagesViewModel()
    
    let value: String
    
    var body: some View {
        List {
            ForEach(viewModel.messagesBubble) { messageBubble in
                MessagesCellView(messageBubble: messageBubble)
            }
        }
        .navigationTitle("Messages")
        .task {
            do {
                try await viewModel.getRoomMessages(room_id: value)
            } catch {
                print("RoomMessagesView - Error getting documents: \(error.localizedDescription)")
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(value: "123456")
    }
}
