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
    
    @Published private(set) var messages: [Message] = []
    
    func fetchLastMessages() async {
        Task {
            
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let user_id = authDataResult.uid
            
            self.messages = try await MessagesManager.shared.getLastMessages(user_id: user_id)
        }
    }
}


struct MessagesView: View {
    
    @StateObject private var viewModel = MessagesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(viewModel.messages) { oneMessage in
                        // Text(oneContact.nom)
                        MessageCellView(messageItem: oneMessage)
                    }
                }
            }
        }
        .task { await viewModel.fetchLastMessages() }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessageCellView(messageItem: Message(room_id: "1", room_name: "Nom du room", from_id: "2", to_id: "3", message_text: "Salut", date_send: Timestamp()))
    }
}
