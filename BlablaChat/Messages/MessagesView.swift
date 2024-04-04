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
    
    // Tous les messages d'un room
    func getRoomMessages(room_id: String) async throws {
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }

        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
    }
        
    func saveMessage(message_text: String, room_id: String) async throws {
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        
        let user_id = AuthUser.uid

        // Recherche du to_id dans member
        let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id)
        
        do {
            try await NewContactManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: message_text, room_id: room_id)
            self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
        } catch {
            print("Error saveMessage: \(error.localizedDescription)")
        }
    }
}

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @State private var messageText: String = ""
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    // <- LastMessagesView
    let value: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.messagesBubble) { messageBubble in
                    MessagesCellView(message: messageBubble)
                }
            }
            .padding(.top, 10)
            .background(.white)
            
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
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
        MessagesView(value: "123")
    }
}

// Barre de saisie du message
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
                    sendButton()
                }
        }
        .font(.headline)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.05))
        )
        .padding()
    }
    
    func sendButton() {
        if textIsCorrect() {
            Task {
                try? await viewModel.saveMessage(message_text: messageText, room_id: value)
            }
        }
    }
    
    func textIsCorrect() -> Bool {
        if messageText.count < 3 {
            alertTitle = "Saisir un message d'au moins 3 caractères"
            showAlert.toggle()
            return false
        }
        return true
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle))
    }

}
