//
//  LastMessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

//struct LastMessageItem: Identifiable, Codable {
//    var id: String = UUID().uuidString
//    let room_id: String
//    let room_name: String
//    let room_date: Timestamp
//    let from_id: String
//    let received: Bool
//    let message_text: String
//    let message_send: Timestamp
//}


struct LastMessagesView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Rooms/lastMessages")
                Text("Rooms/lastMessages")
                Text("Rooms/lastMessages")
                Text("Rooms/lastMessages")
            }
            .navigationTitle("Mes messages")
//            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarItems(
                leading: Image(systemName: "person.fill"),
                trailing: NavigationLink(
                    destination: monProfil(),
                    label: {Image(systemName: "square.and.pencil")}
                )
            )
        }
    }
}

struct monProfil: View {
    var body: some View {
        Text("Contacts")
    }
}

struct LastMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesView()
    }
}
