//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Last: Identifiable {
    let id: String = UUID().uuidString
    let room_id: String
    let room_name: String
    let room_date: String
}

struct LastView: View {
    
    @State var LastArray: [Last] = [
        Last(room_id: "1", room_name: "Essai", room_date: timeStampToString(dateMessage: Timestamp()))
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(LastArray) { un in
                    HStack {
                        Text("\(un.room_name)")
                        Text("\(un.room_date)")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("titre Essai")
            .onAppear {
                getLast()
            }
        }
    }
}

func getLast() {
    let last1 = Last(room_id: "1", room_name: "room1", room_date: timeStampToString(dateMessage: Timestamp()))
}

struct LastView_Previews: PreviewProvider {
    static var previews: some View {
        LastView()
    }
}
