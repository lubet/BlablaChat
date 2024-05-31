//
//  LastMessagesCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI

struct LastMessagesCellView: View {
    
    let lastMessage: LastMessage
    
    var body: some View {
        WebImage(url: URL(string: lastMessage.avatar_link))
            .resizable()
            .frame(width: 20, height: 20)
            .cornerRadius(10)
        
        // email et message
        VStack {
            Text("\(lastMessage.email)")
                .font(.body).bold()
                .foregroundColor(Color.black)
                .frame(width: 160,height: 20 , alignment: .topTrailing)
            HStack{
                // texte du message
                Text("\(lastMessage.message_texte)")
                    .font(.body)
                    .foregroundColor(Color.black)
                    .frame(width: 100,height: 20 , alignment: .topTrailing)
                // date
                Spacer()
                let myDate = timeStampToString(dateMessage: lastMessage.message_date)
                Text("\(myDate)")
                    .font(.footnote)
                    .foregroundColor(Color.black)
                    .frame(width: 100,height: 20 , alignment: .topTrailing)
            }
        }
                
//        HStack {
//            VStack(alignment: .leading) {
//                Text("\(lastMessage.email)")
//                    .font(.body).bold()
//                    //.background(Color.white)
//                    //.frame(width: 200,alignment: .leading)
//                    //.foregroundColor(Color.black)
//                    //.multilineTextAlignment(.leading)
//                
//                Text("\(lastMessage.message_texte)")
//                    .font(.body)
//                    // .background(Color.white)
//                    //.frame(width: 200, height: 10)
//                    .foregroundColor(Color.black)
//                    //.padding()
//                    //.multilineTextAlignment(.leading)
//            }
//            .frame(width: 200,alignment: .leading)
//            let myDate = timeStampToString(dateMessage: lastMessage.message_date)
//            Text("\(myDate)")
//                .font(.footnote)
//                .frame(width: 100,height: 20 ,alignment: .topTrailing)
//                //.background(Color.white)
//        }
        .foregroundColor(Color.black)
        .frame(height: 40)
        .padding(.horizontal, 30)
        //.background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct LastMessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesCellView(lastMessage: LastMessage(avatar_link: "", email: "", message_texte: "", message_date: Timestamp()))
    }
//        LastMessagesCellView(lastMessage: LastMessage(room_id: "1", room_name: "My room B", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Salut les amis", message_date: timeStampToString(dateMessage: Timestamp())  , message_from: "Xavier", message_to: "Message to Alfred"))
}


