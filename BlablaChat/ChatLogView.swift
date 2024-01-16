//
//  ChatLogView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/01/2024.
//
// Tout les messages envoyés à ou reçus d'un contact selectioné
// permettant de créer un nouveau message

import SwiftUI


final class ChatLogViewModel: ObservableObject {
    
    @Published var userChatLog : [UserMessage] = [] // Tout les messages pour un user selectionné
    
    func getUserChatLog(newMessageUserId: String) {
        
        // Mon userId
        let authResult = try? AuthManager.shared.getAuthenticatedUser()
        guard let monUserId = authResult?.uid else { return }
        print("\(monUserId)")
        
        // Fetch de tous les messages me concernant et concernant le user selectionné
        
     }
}

struct ChatLogView: View {
    
    let newMessageUserId: String // User selectionné dans NewMessageView
    
    @State var textMessageField: String = "" // Saisie d'un nouveau message
    
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
