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
    
    @Published var userChatLog : [UserMessage] = [] // Tout les messages pour un user selectionné
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
    
    let selectedUserId: String // From NewMessageView
    
    @State var textMessageField: String = "" // Saisie d'un nouveau message
    
    @StateObject var viewModel = ChatLogViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Email")
                .font(.title)
                .fontWeight(.semibold)
            ScrollView {
                ForEach(1..<15) { message in
                    // un message où je suis présent from ou to
                    BubbleMessageView(message: message, monUserId: viewModel.monUserId)
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .onAppear() {
                viewModel.getUserChatLog(selectedUserID: selectedUserId)
            }
//            TextField("Saisie", text: $textMessageField)
//                .padding(20)
//                .background(Color.gray.opacity(0.3).cornerRadius(10))
//            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView(selectedUserId: "123456")
    }
}
