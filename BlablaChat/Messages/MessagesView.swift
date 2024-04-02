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
    
    var user_id:String = ""
    
    // Tous les messages d'un room
    func getRoomMessages(room_id: String) async throws {
        
        let AuthUser = try AuthManager.shared.getAuthenticatedUser()
        user_id = AuthUser.uid
        
        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: user_id)
    }
        
    func saveMessage(to_id: String, message_text: String, room_id: String) async throws {
        do {
            try await NewContactManager.shared.createMessage(from_id: user_id, to_id: to_id, message_text: message_text, room_id: room_id)
        } catch {
            print("Error saveMessage: \(error.localizedDescription)")
        }
    }
}

struct MessagesView: View {
    
    @StateObject private var viewModel = MessagesViewModel()
    
    @State var messageText: String = ""
    
    let value: String // room_id
    
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
                .onTapGesture {
                    // viewModel.saveMessage(to_id: <#T##String#>, message_text: messageText, room_id: value)
                }
        }
        .font(.headline)
        // .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.05))
        )
        .padding()
    }
}
