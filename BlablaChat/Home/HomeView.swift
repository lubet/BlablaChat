//
//  HomeView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var conversations: [Conversation] = [
        Conversation(titre: "Richard", last_date: Date(), last_message: "Salut Richard, comment vas tu ?"),
        Conversation(titre: "Jean", last_date: Date(), last_message: "Salut Jean"),
        Conversation(titre: "Paul", last_date: Date(), last_message: "Salut Paul"),
        Conversation(titre: "Pierre", last_date: Date(), last_message: "Salut Pierre"),
        Conversation(titre: "Richard", last_date: Date(), last_message: "Salut Richard"),
        Conversation(titre: "Jean", last_date: Date(), last_message: "Salut Jean"),
        Conversation(titre: "Paul", last_date: Date(), last_message: "Salut Paul"),
        Conversation(titre: "Pierre", last_date: Date(), last_message: "Salut Pierre"),
        Conversation(titre: "Richard", last_date: Date(), last_message: "Salut Richard"),
        Conversation(titre: "Jean", last_date: Date(), last_message: "Salut Jean"),
        Conversation(titre: "Paul", last_date: Date(), last_message: "Salut Paul"),
        Conversation(titre: "Pierre", last_date: Date(), last_message: "Salut Pierre")
    ]
}

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    ForEach(viewModel.conversations) { conversation in
                        HomeCellView(conversation: conversation)
                        Divider()
                    }
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
