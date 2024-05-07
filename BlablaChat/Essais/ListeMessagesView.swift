//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//
// View exemple de création de List

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListModel: Identifiable {
    let id: String = UUID().uuidString
    let room_id: String
    let room_name: String
    let room_date: String
    let message_texte: String
    let message_date: String
}

class ListeMessagesViewModel: ObservableObject {
    
    @Published var ListArray: [ListModel] = []
    
    func getLast() {
        let last1 = ListModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Message 1", message_date: timeStampToString(dateMessage: Timestamp()))
        let last2 = ListModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Message 1", message_date: timeStampToString(dateMessage: Timestamp()))
        let last3 = ListModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Message 1", message_date: timeStampToString(dateMessage: Timestamp()))
        let last4 = ListModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Message 1", message_date: timeStampToString(dateMessage: Timestamp()))
        let last5 = ListModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Message 1", message_date: timeStampToString(dateMessage: Timestamp()))

        ListArray.append(last1)
        ListArray.append(last2)
        ListArray.append(last3)
        ListArray.append(last4)
        ListArray.append(last5)
    }

    func deleteLast(index: IndexSet) {
        ListArray.remove(atOffsets: index)
    }

    
}

struct ListeMessagesView: View {
    
    // @ObserverObject relaod si la vue is refresh contrairement à @StateObject
    @ObservedObject var listViewModel: ListeMessagesViewModel = ListeMessagesViewModel()
    
    var body: some View {
        //NavigationView {
            List {
                ForEach(listViewModel.ListArray) { un in
                    HStack {
                        Text("\(un.room_name)")
                        Text("\(un.room_date)")
                        Text("\(un.message_texte)")
                    }
                }
                .onDelete(perform: listViewModel.deleteLast)
            }
            // .listStyle()
            .navigationTitle("Messages")
            .onAppear {
                listViewModel.getLast()
            }
            .navigationBarItems(
                leading: Image(systemName: "person.fill"),
                trailing: NavigationLink(
                    destination: MonProfil(),
                    label: {Image(systemName: "square.and.pencil")}
                )
            )
        //}
    }
}

struct MonProfil: View {
    var body: some View {
        Text("Contacts")
    }
}
struct ListeMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        ListeMessagesView()
    }
}
