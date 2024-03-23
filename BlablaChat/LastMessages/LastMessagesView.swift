//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import SwiftUI

class LastMessagesViewModel: ObservableObject {
    
    @Published var LastArray: [LastModel] = []
    
    func getLast() {

    }

    func deleteLast(index: IndexSet) {
        LastArray.remove(atOffsets: index)
    }

    
}

struct LastMessagesView: View {
    
    // @ObserverObject relaod si la vue is refresh contrairement à @StateObject
    @ObservedObject var lastViewModel: LastMessagesViewModel = LastMessagesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(lastViewModel.LastArray) { un in
                    HStack {
                        Text("\(un.room_name)")
                        Text("\(un.room_date)")
                        Text("\(un.message_texte)")
                    }
                }
                .onDelete(perform: lastViewModel.deleteLast)
            }
            // .listStyle()
            .navigationTitle("Messages")
            .onAppear {
                lastViewModel.getLast()
            }
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
