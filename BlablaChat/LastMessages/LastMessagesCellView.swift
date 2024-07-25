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
                
                SDWebImageLoader(url: lastMessage.avatar_link, size: 40)
                
                // WebImage(url: URL(string: lastMessage.avatar_link))
                VStack(alignment: .leading) {
                    let emailShort = EmailShort(email: lastMessage.email)
                    Text("\(emailShort)")
                        .frame(width: 150,alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        .background(Color(.red))
                    let msg = MessageShort(message: lastMessage.message_texte)
                    Text("\(msg)")
                        .frame(width: 150, alignment: .leading)
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .background(Color(.bleu))
                }
                //Spacer()
                // let myDate = timeStampToString(dateMessage: lastMessage.message_date)
                VStack(alignment: .leading) {
                    let myDate = dateManager(dateMessage: lastMessage.message_date)
                    Text("\(myDate)")
                        .frame(width: 50, alignment: .leading)
                        .font(.system(size: 8, weight: .semibold))
                        .background(Color(.gray))
                }
            }
            .padding(.vertical,8)
        }.padding(.horizontal)
    }
}

struct LastMessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesCellView(lastMessage: LastMessage(avatar_link: "", email: "xlubet-moncla@wanadoo.fr", message_texte: "Hello toto, comment vas tu et toi cela va bien", message_date: Timestamp()))
    }
}


