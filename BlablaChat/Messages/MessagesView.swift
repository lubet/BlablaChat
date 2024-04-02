//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//
// Messages Bubble
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
    
    @State var messageText: String = ""
    
    let value: String
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(viewModel.messagesBubble) { messageBubble in
                    MessagesCellView(message: messageBubble)
                }
            }
            .padding(.top, 10)
            .background(.white)
            
            MessageBar
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

extension MessagesView {
    
    private var MessageBar: some View {
        
        HStack {
            Image(systemName: "xmark.circle")
                .foregroundColor(Color.black)
                .onTapGesture {
                    messageText = ""
                }

            TextField("Message", text: $messageText, axis: .vertical)
                .foregroundColor(Color.black)

            Image(systemName: "paperplane.circle")
                .padding()
                .offset(x:10)
                .foregroundColor(Color.blue)
                .opacity(messageText.isEmpty ? 0.0 : 1.0)
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.05))
        )
        .padding()
    }
}
