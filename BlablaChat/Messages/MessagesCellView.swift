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
                VStack() {
                    Text("\(messageItem.room_name)")
                        .font(.body).bold()
                        //.background(Color.white)
                        //.frame(width: 200,alignment: .leading)
                        .foregroundColor(Color.black)
                        //.multilineTextAlignment(.leading)
                    
                    Text("\(messageItem.message_text)")
                        .font(.body)
                        //.background(Color.white)
                        //.frame(width: 200, height: 10, alignment: .leading)
                        .foregroundColor(Color.black)
                        //.padding()
                        //.multilineTextAlignment(.leading)
                }
                .frame(width: 200,alignment: .leading)
                let myDate = timeStampToString(dateMessage: messageItem.message_send)
                Text("\(myDate)")
                    .font(.footnote)
                    .frame(width: 100,height: 20 ,alignment: .topTrailing)
                    //.background(Color.white)
            }
            .foregroundColor(Color.black)
            .frame(height: 80)
            .padding(.horizontal, 30)
            //.background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
    }
}

struct MessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        MessageCellView(messageItem: MessageItem(room_id: "1", room_name: "My Room A", room_date: Timestamp(), from_id: "2", received: true, message_text: "Salut Maurice", message_send: Timestamp()))
    }
}
