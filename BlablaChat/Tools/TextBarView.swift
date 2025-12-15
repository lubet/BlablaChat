//
//  TextBarView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/04/2024.
//

import SwiftUI

struct TextBarView: View {
    
    @State var messageText: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "xmark.circle")
                .foregroundColor(Color.black)
                .onTapGesture {
                    messageText = ""
                }

            TextField("Message...", text: $messageText)
                .foregroundColor(Color.black)
                .overlay (
                    Image(systemName: "paperplane.circle")
                        .padding()
                        .offset(x:10)
                        .foregroundColor(Color.blue)
                        .opacity(messageText.isEmpty ? 0.0 : 1.0)
                    , alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.05))
        )
        .padding()
    }
}

struct TextBarView_Previews: PreviewProvider {
    static var previews: some View {
        TextBarView()
    }
}
