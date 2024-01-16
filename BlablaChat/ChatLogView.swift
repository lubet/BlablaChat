//
//  ChatLogView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/01/2024.
//
// View vide avec en base un saise de message et une photo

import SwiftUI


final class ChatLogViewModel: ObservableObject {
    
    @Published var userChatLog : [UserMessage] = []
    
    // Fetch les messages qui me sont destinés de la part du user selectioné dans la liste
    func getUserChatLog(userId: String) {
        let authResult = try? AuthManager.shared.getAuthenticatedUser()
        guard let monUserId = authResult?.uid else { return } // mon userID
        print("\(monUserId)")
     }
}

struct ChatLogView: View {
    
    let newMessageUserId: String // From NewMessageView
    
    @State var textMessageField: String = ""
    
    @StateObject var viewModel = ChatLogViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            ScrollView {
                ForEach(1..<10) { message in
                    BubbleMessageView(message: message)
                }
            }
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(newMessageUserId: "123456")
    }
}
