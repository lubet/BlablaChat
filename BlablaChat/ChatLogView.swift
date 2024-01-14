//
//  ChatLogView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/01/2024.
//

import SwiftUI


final class ChatLogViewModel: ObservableObject {
    
    @Published var userChatLog : [UserMessage] = []
    
    // Fetch les messages qui me sont destinés de la part du user selectioné dans la liste
    func getUserChatLog(userId: String) {
        let authResult = try? AuthManager.shared.getAuthenticatedUser()
        guard let authId = authResult?.uid else { return }
        print("\(authId)")
        
    }
    
}

struct ChatLogView: View {
    
    @StateObject var viewModel = ChatLogViewModel()
    
    var body: some View {
        ZStack {
            ScrollView {
                List {
                    
                }
                .onAppear {
                    // viewModel.getUserChatLog(userId: <#T##String#>)
                }
            }
            .navigationTitle("Chat log")
         }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        ChatLogView()
    }
}
