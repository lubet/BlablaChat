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

    var userMessages: [UserMessage] = [
        UserMessage(id: "123", from: "123", to: "123", texte: "Salut les amis*", dateCreated: Date()),
        UserMessage(id: "1234", from: "123", to: "123", texte: "Salut la compagnie", dateCreated: Date()),
        UserMessage(id: "1235", from: "123", to: "123", texte: "Salut tout", dateCreated: Date()),
        UserMessage(id: "1236", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "1237", from: "123", to: "123", texte: "Bonjour*******", dateCreated: Date()),
        UserMessage(id: "1238", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "1239", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "12310", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "12311", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "12312", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "12313", from: "123", to: "123", texte: "Salu", dateCreated: Date()),
        UserMessage(id: "12314", from: "123", to: "123", texte: "Salu", dateCreated: Date())
    ]
    
    var body: some View {
        VStack {
            Text("Email")
            ScrollView {
                ForEach(userMessages) { message in
                    MessageBubbleView(message: message)
                }
                .navigationBarHidden(true)
                .navigationTitle("email")
                .onAppear() {
                    viewModel.getUserChatLog(selectedUserID: selectedUserId)
                }
            }
            .background(Color("GrisClair"))
            HStack {
                Spacer().frame(height: 20)

            }
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(selectedUserId: "123456")
    }
}
