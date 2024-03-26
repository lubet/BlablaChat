//
//  FirstMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/01/2024.
//
// View Nouveau message -> Création d'un chat et de ce message

import SwiftUI

@MainActor
final class HandleSendViewModel: ObservableObject {
    
    @Published var chatText: String = ""
    
    func handleSend(from_email: String, to_email: String) {
        
//        let chatId = ChatManager.shared.addChat(title: chatText, last_message: "Salut les amis")
//
//        ChatManager.shared.addMessage(chat_id: chatId, texte: chatText, from_email: from_email)

    }
}

struct HandleSendView: View {
    
    @StateObject private var viewModel = HandleSendViewModel()

    let from_email: String = "12" // expediteur
    let to_email: String = "11" // destinaire

    var body: some View {
        // NavigationView {
            VStack {
                Spacer()
                HStack {
                    TextEditor(text: $viewModel.chatText)
                        .frame(height: 60)
                         .foregroundColor(.black)
                         .cornerRadius(20)
                         .background(Color.white)
                    Button {
                        viewModel.handleSend(from_email: from_email, to_email: to_email)
                    } label: {
                        Image(systemName: "paperplane")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .navigationTitle("Nouveau message")
            .background(Color.gray.opacity(0.3).cornerRadius(10))
        //}
    }
}

struct HandleSendView_Previews: PreviewProvider {
    static var previews: some View {
        HandleSendView()
        // HandleSendView(to_user: DBUser(userId: "123456", email: "toto@test.com", dateCreated: Date(), imageLink: "https://"), from_user: DBUser(userId: "789012", email: "toto@test.com", dateCreated: Date(), imageLink: "https://"))
    }
}
