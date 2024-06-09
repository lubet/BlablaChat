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
                    .frame(width: 64, height: 64)
                    .clipped()
                    .cornerRadius(64)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color.black, lineWidth: 1))
                
                VStack(alignment: .leading) {
                    Text("\(lastMessage.email)")
                        .font(.system(size: 16, weight: .bold))
                    Text("\(lastMessage.message_texte)")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                let myDate = timeStampToString(dateMessage: lastMessage.message_date)
                Text("\(myDate)")
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(.vertical,8)
        }//.padding(.horizontal)
    }
}

struct LastMessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessagesCellView(lastMessage: LastMessage(avatar_link: "", email: "xlubet-moncla@", message_texte: "Hello toto", message_date: Timestamp()))
    }
}


