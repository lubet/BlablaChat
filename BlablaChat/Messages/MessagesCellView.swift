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
                let myDate = Date.timeStampToString(dateMessage: messageItem.message_send)
                Text("\(myDate)")
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
        MessageCellView(messageItem: MessageItem(room_id: "1", room_name: "my room", room_date: Timestamp(), from_id: "2", to_id: "3", message_text: "Salut Maurice", message_send: Timestamp()))
    }
}

extension Date {
    static func timeStampToString(dateMessage: Timestamp) -> String {
        let date = dateMessage.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "FR-fr")
        let strDate = "\(dateFormatter.string(from: date))"
        print("date french str: \(strDate)")
        return strDate
    }
}
