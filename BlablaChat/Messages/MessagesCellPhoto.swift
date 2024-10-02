//
//  MessagesCellPhoto.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 10/04/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import SDWebImageSwiftUI

struct MessagesCellPhoto: View {
    
    var message: MessageBubble
    
    @State private var showTime: Bool = false
    
    @State private var showScreenCover: Bool = false
    
    var body: some View {
        VStack(alignment: message.received ? .leading : .trailing) {
            HStack {
                WebImage(url: URL(string: message.imageLink))
                    .resizable()
                    // .scaledToFill()
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    //.shadow(radius: 10)
            }
            .frame(maxWidth: 300, alignment: message.received ? .leading : .trailing)

//            .onTapGesture {
//                showTime.toggle()
//            }
            
            .onTapGesture(count: 2) {
                showScreenCover.toggle()
            }
            
            .fullScreenCover(isPresented: $showScreenCover, content: {
                MessageBigImage(image: message.imageLink)
            })
            
            if showTime {
                Text("\(message.message_date)")
                    .font(.caption2)
                    .foregroundColor(.black)
                    .padding(message.received ? .leading : .trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.received ? .leading : .trailing)
        .padding(message.received ? .leading : .trailing)
        .padding(.horizontal,10)
    }
}

struct MessagesCellPhoto_Previews: PreviewProvider {
    static var previews: some View {
        MessagesCellPhoto(message: MessageBubble(id: "123456", message_text: "Coucou, ceci est un exemple de message qui est envoyé à quelqu'un por qu'il puisse me répondre dans les plus brefs délais", message_date: "12/01/2024", received: true, imageLink: "https...", to_id: "123456"))
    }
}
