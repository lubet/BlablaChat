//
//  HomeView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    // @Published private(set) var lastMessage: [LastMessage] = []
    
    
    init() {
        Task {
            try await getLastMessages()
        }
    }
    
    func getLastMessages() async throws {
        // mon user_id:
        // let AuthUser = try AuthManager.shared.getAuthenticatedUser()
        
        // extraire tous les messages dont le from_id = user_id
        // pour chaque message prendre le conversation_id
            // boucle extraire tous les messages avec ce conversation_id
        //
        
        // ou
        
        // extraire tous les messages M1
        // filtrer form_id = user_id, conversation_id -> M2
        // selectionner dans M1 tous les message dont le convesation_id = conversation_id de M2
        
        try await HomeManager.shared.lastMessages(from_to: "123")
        
        
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
