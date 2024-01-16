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
    
    var body: some View {
            ScrollView {
                ForEach(1..<15) { message in
                    HStack {
                        //Spacer()
                        Text("Ceci est un essai")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                
                HStack{ Spacer() }
            }
            .navigationBarHidden(true)
            .navigationTitle("email")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.lightGray))
            Text("Ici my chat bar")
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
