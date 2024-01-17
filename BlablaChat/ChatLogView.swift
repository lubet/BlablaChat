//
//  ChatLogView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/01/2024.
//
// Tout les messages envoyés à ou reçus de, pour un contact selectioné,
// avec possibilité de saisir un nouveau message

import SwiftUI


final class ChatLogViewModel: ObservableObject {
    
    @Published var userChatLog : [UserMessage] = [] // Tout les messages me concernant
    @Published var monUserId: String = ""
    
    func getUserChatLog(selectedUserID: String) {
        
        // Mon userId
        let authResult = try? AuthManager.shared.getAuthenticatedUser()
        guard let monUserId = authResult?.uid else { return }
        print("\(monUserId)")
        
        // Fetch de tous les messages avec monUserId et le selectedUserId
     }
}

struct ChatLogView: View {
    
    let selectedUserId: String // <-From NewMessageView
    
    @State var textMessageField: String = "" // Saisie d'un nouveau message
    
    @StateObject var viewModel = ChatLogViewModel()

    var UserMessages = [
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "123", from: "123", to: "123", texte: "Salu", dateCreated: Date())
    ]
    
    var body: some View {
            ScrollView {
                ForEach(UserMessages) { message in
                    // BubbleMessageView(message: 5, monUserId: "123")
                    MessageBubbleView(message: message)
                }
                HStack{ Spacer() }
            }
            .navigationBarHidden(true)
            .navigationTitle("email")
            .onAppear() {
                viewModel.getUserChatLog(selectedUserID: selectedUserId)
            }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(selectedUserId: "123456")
    }
}
