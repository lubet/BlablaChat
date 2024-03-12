//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 11/03/2024.
//

import SwiftUI


@MainActor
final class MessagesViewModel: ObservableObject {
    
    @Published private(set) var messages: [Message] = []
    
    func getLastMessages(user_id: String) {
        self.messages = MessagesManager.shared.getLastMessages(user_id: user_id)
    }
    
}


struct MessagesView: View {
    
    @StateObject private var viewModel = MessagesViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
