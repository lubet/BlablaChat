//
//  SearchBarView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/01/2024.
//
// A utliser pour saisir un message

import SwiftUI

struct MessageBarView: View {
    
    @State var messageText: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "photo.on.rectangle")
                .foregroundColor(messageText.isEmpty ?
                                 Color.black: Color.white
                )
            TextEditor(text: $messageText)
                .scrollContentBackground(.hidden) // <- Hide it
                .background(Color(.init("GrisClair"))) // To see this
                .frame(height: 30)
                .foregroundColor(Color.black)
                .overlay (
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x:10)
                        .foregroundColor(Color.black)
                        .onTapGesture {
                            messageText = ""
                        }
                    ,alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.init("GrisClair")))
                .shadow(radius: 2)
        )
        .padding()
    }
}

struct MessageBarView_Previews: PreviewProvider {
    static var previews: some View {
        MessageBarView()
    }
}
