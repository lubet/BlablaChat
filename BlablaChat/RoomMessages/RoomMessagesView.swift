//
//  RoomMessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 26/03/2024.
//
// Tous les messages concernant un room triés par date décroissante
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class RoomMessagesViewModel: ObservableObject {
    
    @Published private(set) var RoomMessages: [Message] = []
    
    func getRoomMessages(room_id: String) async throws {
    
        let RoomMessages = try await RoomMessagesManager.shared.getRoomMessages(room_id: room_id)
    }
    
}


struct RoomMessagesView: View {
    
    @StateObject var viewModel = RoomMessagesViewModel()
    
    let value: String
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.RoomMessages) { message in
                Text("\(message.message_text)")
            }
        }
        .task {
            try? await viewModel.getRoomMessages(room_id: value)
        }
    }
}

struct RoomMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        RoomMessagesView(value: "Essai")
    }
}
