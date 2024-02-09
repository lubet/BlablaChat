//
//  MyChatsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/02/2024.
//
// Liste des chats

import SwiftUI

@MainActor
final class ChatsListViewModel: ObservableObject {
    
    @Published private(set) var chats: [String] = []
        
    func fetchChats() async throws {
        let authUser = try? AuthManager.shared.getAuthenticatedUser()
        let auth_email = authUser?.email ?? "n/a"
        let chats_id = try await ChatsListManager.shared.getChatsId(auth_email: auth_email)
        print("chats_id: \(chats_id)")
    }
}

struct ChatsListView: View {
    
    @StateObject var viewModel: ChatsListViewModel = ChatsListViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Text("aaa")
                Text("bbbb")
            }
        }
        .onAppear() {
            Task {
                try await viewModel.fetchChats()
            }
        }
    }
}

struct MyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListView()
    }
}
