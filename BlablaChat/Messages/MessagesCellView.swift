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
    
    let messageBubble: MessageBubble
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    
    
}

struct MessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesCellView(messageBubble: MessageBubble(id: "123456", message_text: "Coucou", message_date: "12/01/2024"))
    }
}
