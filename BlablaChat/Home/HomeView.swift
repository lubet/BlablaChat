//
//  HomeView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published private(set) var MesMessages: [(conversation: Conversation, messag: Message)] = []
    
    func getMesMessages() {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            let myMessages = try await HomeManager.shared.getMyMessages(user_id: authDataResult.uid)
            
            var localArray: [(conversation: Conversation, messag: Message)] = []
            
            for myMessage in myMessages {
                if let chat = try? await HomeManager.shared.getConversation(chatRoom_id: myMessage.conversation_id) {
                    localArray.append((chat, myMessage))
                }
            }
            self.MesMessages = localArray
        }
    }
 }

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer()
//                        ForEach(viewModel.conversations) { conversation in
//                            HomeCellView(conversation: conversation)
//                            Divider()
//                        }
                    }
                }
                .navigationTitle("Conversations")
                .navigationDestination(for: String.self) {value in
                    Text("\(value)")
                }
            }
        }
    }



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

extension Date {
    var displayFormat: String {
//                self.formatted(
//                    .dateTime
//                        .locale(.init(identifier: "fr"))
//                )
        self.formatted(date: .omitted, time: .standard)
    }
}
