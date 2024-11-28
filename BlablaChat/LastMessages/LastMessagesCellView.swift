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
        
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            HStack(spacing: 0) {
                SDWebImageLoader(url: lastMessage.avatar_link, size: 40)
                VStack(alignment: .leading) {
                    
                    let emailShort = EmailShort(email: lastMessage.email)
                    Text("\(emailShort)")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.leading, 20)
                    
                    let msg = MessageShort(message: lastMessage.message_texte)
                    Text("\(msg)")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 20)
                }
                Spacer()
                
                let myDate = dateManager(dateMessage: lastMessage.message_date)
                Text("\(myDate)")
                    .font(.system(size: 10, weight: .semibold))
            }
        }
    }
}

struct LastMessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesCellView(lastMessage: LastMessage(avatar_link: "", email: "xlubet-moncla@wanadoo.fr", message_texte: "Hello toto, comment vas tu et toi cela va bien", message_date: Timestamp()))
    }
}


