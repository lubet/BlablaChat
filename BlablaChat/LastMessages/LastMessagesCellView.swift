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
        
        VStack {
            HStack(spacing: 16) {
                WebImage(url: URL(string: lastMessage.avatar_link))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipped()
                    .cornerRadius(40)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color.black, lineWidth: 1))

                
//                    .font(.system(size: 32))
//                    .padding(8)
//                    .overlay(RoundedRectangle(cornerRadius: 44)
//                        .stroke(Color.black, lineWidth: 1))
                
                VStack(alignment: .leading) {
                    Text("\(lastMessage.email)")
                        .font(.system(size: 16, weight: .bold))
                    Text("\(lastMessage.message_texte)")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                }
                Spacer()
                let myDate = timeStampToString(dateMessage: lastMessage.message_date)
                Text("\(myDate)")
                    .font(.system(size: 14, weight: .semibold))
            }
            Divider()
            .padding(.vertical,8)
        }//.padding(.horizontal)
    }
}
        
        
        
        // avatar
//        WebImage(url: URL(string: lastMessage.avatar_link))
//            .resizable()
//            .frame(width: 20, height: 20)
//            .cornerRadius(10)
//        
//        VStack {
//            
//            Text("\(lastMessage.email)")
//                .font(.body).bold()
//                .foregroundColor(Color.black)
//                .frame(width: 160,height: 20 , alignment: .topTrailing)
//            
//            HStack{
//                
//                // texte du message
//                Text("\(lastMessage.message_texte)")
//                    .font(.body)
//                    .foregroundColor(Color.black)
//                    .frame(width: 100,height: 20 , alignment: .topTrailing)
//            
//                // date
//                Spacer()
//                let myDate = timeStampToString(dateMessage: lastMessage.message_date)
//                Text("\(myDate)")
//                    .font(.footnote)
//                    .foregroundColor(Color.black)
//                    .frame(width: 100,height: 20 , alignment: .topTrailing)
//            }
//        }
//                
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
//        .foregroundColor(Color.black)
//        .frame(height: 40)
//        .padding(.horizontal, 30)
//        //.background(Color(UIColor.secondarySystemBackground))
//        .cornerRadius(10)
//    }
//}

struct LastMessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesCellView(lastMessage: LastMessage(avatar_link: "", email: "xlubet-moncla@", message_texte: "Hello toto", message_date: Timestamp()))
    }
}


