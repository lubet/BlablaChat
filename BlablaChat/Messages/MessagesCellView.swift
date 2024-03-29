//
//  MessagesCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessagesCellView: View {
    
    let message: [Message]
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesCellView(message: [Message(id: "123456", from_id: "123", to_id: "123", message_text: "Coucou",
                        date_send: Timestamp(), room_id: "123")])
    }
}
