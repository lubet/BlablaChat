//
//  MessagesCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessagesCellView: View {
    
    var message: MessageBubble
    
    @State private var showTime: Bool = false
    
    var body: some View {
        VStack(alignment: message.received ? .leading : .trailing) {
            HStack {
                Text(message.message_text)
                    .padding()
                    .background(message.received ? Color("Gris") : Color("BleuMauve"))
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: message.received ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
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

struct MessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesCellView(message: MessageBubble(id: "123456", message_text: "Coucou, ceci est un exemple de message qui est envoyé à quelqu'un por qu'il puisse me répondre dans les plus brefs délais", message_date: "12/01/2024", received: true))
    }
}
