//
//  MessagesCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 12/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessageCellView: View {
    
    let messageItem: MessageItem
    
    var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(messageItem.message_text)")
                        .font(.headline)
                        .frame(width: 200,alignment: .leading)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                        .multilineTextAlignment(.leading)
                }
                Text("\(messageItem.message_send)")
                    .font(.footnote)
                    .frame(width: 100,height: 50 ,alignment: .topTrailing)
                    .background(Color.green)
            }
            .foregroundColor(Color.black)
            .padding(.horizontal)
            .background(Color.blue)
    }
}

struct MessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        MessageCellView(messageItem: MessageItem(room_id: "1", room_name: "my room", room_date: Timestamp(), from_id: "2", to_id: "3", message_text: "Salut", message_send: Timestamp()))
    }
}
