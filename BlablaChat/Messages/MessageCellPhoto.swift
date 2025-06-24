//
//  MessageCellPhoto.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/01/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI

struct MessageCellPhoto: View {
    var message: Messages
    
    @State private var showTime: Bool = false
    
    @State private var showScreenCover: Bool = false
    
    var body: some View {
        VStack(alignment: message.send ? .leading : .trailing) {
            HStack {
                WebImage(url: URL(string: message.urlPhoto))
                    .resizable()
                    // .scaledToFill()
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    //.shadow(radius: 10)
            }
            .frame(maxWidth: 300, alignment: message.send ? .leading : .trailing)

//            .onTapGesture {
//                showTime.toggle()
//            }
            
            .onTapGesture(count: 1) {
                showScreenCover.toggle()
            }
            
            .fullScreenCover(isPresented: $showScreenCover, content: {
                MessageBigImage(urlImage: message.urlPhoto)
            })
            
            if showTime {
                Text("\(message.dateMessage)")
                    .font(.caption2)
                    .foregroundColor(.black)
                    .padding(message.send ? .leading : .trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.send ? .leading : .trailing)
        .padding(message.send ? .leading : .trailing)
        .padding(.horizontal,10)
    }
}

#Preview {
    MessageCellPhoto(message: Messages(id: "123", salonId: "123", send: true, fromId: "123", texte: "Bonjour", dateMessage: Timestamp(), urlPhoto: "https://picsum.photos/400", toId: "123456", dateSort: Date()))
}
