//
//  HomeView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published private(set) var chatList: [ChatItem] = [] // nok car pas la même structure
    
    // TODO faire plutot une structure avec l'id et le nom de la conversation et les infos du message
    func getMesMessages() {
        Task {
            let authDataResult = try AuthManager.shared.getAuthenticatedUser()
            
            print("user_id \(authDataResult.uid)")
            
            let myMessages = try await HomeManager.shared.getMyMessages(user_id: authDataResult.uid)
            for myMessage in myMessages {
                if let conversations = try? await HomeManager.shared.getConversation(conversation_id: myMessage.conversation_id) {
                    for conversation in conversations {
                        chatList.append(ChatItem(conversation_id: conversation.conversation_id,
                                                    conversation_name: conversation.conversation_name,
                                                    from_id: myMessage.from_id,
                                                    to_id: myMessage.to_id,
                                                    message_text: myMessage.message_text,
                                                    date_send: myMessage.date_send
                        ))
                     }
                }
            }
            print("MesMessages \(chatList)")
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
                        List {
                                ForEach (viewModel.chatList) { chat in
                                    // print("\(msg)")
                                    HomeCellView(chatItem: chat)
                                }
                        }
                    }
                }
                .navigationTitle("HomeView")
                .onAppear() {
                        viewModel.getMesMessages()
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
