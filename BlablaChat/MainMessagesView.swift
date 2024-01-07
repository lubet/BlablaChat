//
//  MainMessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 07/01/2024.
//

import SwiftUI

@MainActor
final class MainMessagesViewModel : ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await FirestoreManager.shared.getUser(userId: authResult.uid)
    }
    
    
}

struct MainMessagesView: View {
    
    @StateObject private var viewModel = MainMessagesViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
