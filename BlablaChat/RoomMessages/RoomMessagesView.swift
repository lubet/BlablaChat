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
        self.RoomMessages = try await RoomMessagesManager.shared.getRoomMessages(room_id: room_id)
        print("RoomMessages: \(RoomMessages)")
    }
    
}


struct RoomMessagesView: View {
    
    @StateObject private var viewModel = RoomMessagesViewModel()
    
    
    let value: String
    
    var body: some View {
        List {
            ForEach(viewModel.RoomMessages) { message in
                Text("\(message.message_text)")
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

struct RoomMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        RoomMessagesView(value: "Essai")
    }
}
