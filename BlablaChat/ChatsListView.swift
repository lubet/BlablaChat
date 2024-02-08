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
        
    func loadChats() {
//        chats.append("aaaaa","rrrrr")
//        chats.append("bbbbbb","gggg")
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
            viewModel.loadChats()
        }
    }
}

struct MyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListView()
    }
}
