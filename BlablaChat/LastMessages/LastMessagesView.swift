//
//  LastMessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LastMessageItem: Identifiable {
    let id: String = UUID().uuidString
    let room_id: String
    let room_name: String
    let room_date: Date
}

@MainActor
final class LastMessagesViewModel: ObservableObject {
    
    @Published private(set) var lastMessages: [LastMessageItem] = []

    func addLastMessages() {
        let lastMessages = [
            LastMessageItem(room_id: "1", room_name: "room1", room_date: Date())
        ]
        
        print(lastMessages)
    }
}


struct LastMessagesView: View {
    
    @StateObject var viewModel = LastMessagesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(viewModel.lastMessages) { lastMessage in
                        Text("\(lastMessage.room_name)")
                    }
                }
            }
            .onAppear(perform: { viewModel.addLastMessages() })
            .navigationTitle("Last Messages")
            .navigationBarItems(
                // leading: Image(systemName: "person.fill"),
                trailing: NavigationLink(
                    destination: monProfil(),
                    label: {Image(systemName: "square.and.pencil")}
                )
            )
        }
    }
}

//struct monProfil: View {
//    var body: some View {
//        Text("Contacts")
//    }
//}

struct LastMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesView()
    }
}
