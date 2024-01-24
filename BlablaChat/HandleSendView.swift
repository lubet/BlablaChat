//
//  FirstMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/01/2024.
//
// View Nouveau message -> Création d'un chat et de ce message

import SwiftUI

final class HandleSendViewModel: ObservableObject {
    
    @Published var chatText: String = ""
    @Published var from_user: DBUser?
    @Published var to_user: DBUser?
    
    
    func handleSend(from_user: DBUser, to_user: DBUser) {
        print("Zut")
        // _ = ChatManager.shared.addChat(title: chatText, last_message: chatText)
        // print("chat_id: \(chat_id)")
        // ChatManager.shared.addMessage(chat_id: chat_id, texte: chatText, from_user_id: from_user.userId)
        // print("2")
    }
}

struct HandleSendView: View {
    
    let to_user: DBUser? // destinaire
    let from_user: DBUser? // expediteur
    
    @StateObject private var vm = HandleSendViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    TextEditor(text: $vm.chatText)
                        .frame(height: 60)
                         .foregroundColor(.black)
                         .cornerRadius(20)
                         .background(Color.white)
                    Button {
                        guard let from_user = from_user, let to_user = to_user else {
                            print("empty from_user ou to_user")
                            return
                        }
                            vm.handleSend(from_user: from_user, to_user: to_user)
                    } label: {
                        Image(systemName: "paperplane")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .navigationTitle("Nouveau message")
            .background(Color.gray.opacity(0.3).cornerRadius(10))
        }
    }
}

struct HandleSendView_Previews: PreviewProvider {
    static var previews: some View {
        HandleSendView(to_user: DBUser(userId: "123456", email: "toto@test.com", dateCreated: Date(), imageLink: "https://"), from_user: DBUser(userId: "789012", email: "toto@test.com", dateCreated: Date(), imageLink: "https://"))
    }
}
