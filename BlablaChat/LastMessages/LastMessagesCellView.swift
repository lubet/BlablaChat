//
//  LastMessagesCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LastMessagesCellView: View {
    
    let lastMessage: LastMessage
    
    var body: some View {
        HStack {
            VStack() {
                Text("\(lastMessage.room_name)")
                    .font(.title)
                    .background(Color.white)
                    .frame(width: 200,alignment: .leading)
                    .foregroundColor(Color.black)
                    //.multilineTextAlignment(.leading)
                
                Text("\(lastMessage.message_texte)")
                    .font(.body)
                    .background(Color.white)
                    .frame(width: 200, height: 10, alignment: .leading)
                    .foregroundColor(Color.black)
                    //.padding()
                    //.multilineTextAlignment(.leading)
            }
            let myDate = lastMessage.message_date
            Text("\(myDate)")
                .font(.footnote)
                .frame(width: 100,height: 40 ,alignment: .topTrailing)
                .background(Color.white)
        }
        .foregroundColor(Color.black)
        .frame(height: 80)
        .padding(.horizontal, 30)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct LastMessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesCellView(lastMessage: LastMessage(room_id: "1", room_name: "My room B", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Salut les amis", message_date: timeStampToString(dateMessage: Timestamp())  , message_from: "Xavier"))
    }
}
