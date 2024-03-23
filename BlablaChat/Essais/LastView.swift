//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LastModel: Identifiable {
    let id: String = UUID().uuidString
    let room_id: String
    let room_name: String
    let room_date: String
}

class LastViewModel: ObservableObject {
    
    @Published var LastArray: [LastModel] = []
    
    func getLast() {
        let last1 = LastModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()))
        let last2 = LastModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()))
        let last3 = LastModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()))
        let last4 = LastModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()))
        let last5 = LastModel(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()))

        LastArray.append(last1)
        LastArray.append(last2)
        LastArray.append(last3)
        LastArray.append(last4)
        LastArray.append(last5)
    }

    func deleteLast(index: IndexSet) {
        LastArray.remove(atOffsets: index)
    }

    
}

struct LastView: View {
    
    // @ObserverObject relaod si la vue is refresh contrairement à @StateObject
    @ObservedObject var lastViewModel: LastViewModel = LastViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(lastViewModel.LastArray) { un in
                    HStack {
                        Text("\(un.room_name)")
                        Text("\(un.room_date)")
                    }
                }
                .onDelete(perform: lastViewModel.deleteLast)
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("titre Essai")
            .onAppear {
                lastViewModel.getLast()
            }
        }
    }
}

struct LastView_Previews: PreviewProvider {
    static var previews: some View {
        LastView()
    }
}
