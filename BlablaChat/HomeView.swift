//
//  HomeView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/02/2024.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    struct Conversation: Identifiable {
        let id: String = UUID().uuidString
        let titre: String
        let last_date: Date
        let last_message:String
    }

    @Published var conversations: [Conversation] = [
        Conversation(titre: "Richard", last_date: Date(), last_message: "Salut Richard"),
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
                VStack(spacing: 40) {
                    Spacer()
                    ForEach(viewModel.conversations) { conversation in
                        NavigationLink(value: conversation.titre) {
                            HStack {
                                Image(systemName: "person.fill")
                                VStack{
                                    Text("\(conversation.titre)")
                                    Text("\(conversation.last_message)")
                                }
                                Text("\(conversation.last_date.displayFormat)")
                            }
                        }
                    }
                    .font(.title)
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
        self.formatted(date: .omitted, time: .shortened)
    }
}
