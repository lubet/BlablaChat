//
//  RoomMessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 26/03/2024.
//
// Tous les messages concernant un room triés par date décroissante
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RoomMessagesView: View {
    
    let value: String
    
    var body: some View {

        Text("value \(value)")
    }
}

struct RoomMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        RoomMessagesView(value: "Essai")
    }
}
