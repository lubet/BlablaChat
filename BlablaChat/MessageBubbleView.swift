//
//  BubbleMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/01/2024.
//
// * Il me faut l'obj

import SwiftUI

struct MessageBubbleView: View {
    
    var message: UserMessage
     
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Text(message.texte)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.top,8)
    }
}

struct MessageBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubbleView(message: UserMessage(id: "123", from: "456", to: "987", texte: "Salut les copains***", dateCreated: Date()))
    }
}
