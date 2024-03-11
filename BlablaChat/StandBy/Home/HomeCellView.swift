//
//  HomeCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/02/2024.
//
// Liste des derniers chats

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct HomeCellView: View {
    
    let chatItem: ChatItem
    
    var body: some View {
        NavigationLink(value: chatItem.room_name) {
            HStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.horizontal, 20)
                    .frame(width: 60, alignment: .center)
                    .background(Color.green)

                VStack(alignment: .leading){
                    Text("\(chatItem.room_name)")
                        .font(.headline)
                        .frame(width: 200, alignment: .leading)
                        .background(Color.green)
                    Text("\(chatItem.message_text)")
                        .font(.headline)
                        .frame(width: 200,alignment: .leading)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                        .multilineTextAlignment(.leading)
                        
                }
                Text("\(chatItem.date_send)")
                    .font(.footnote)
                    .frame(width: 100,height: 50 ,alignment: .topTrailing)
                    .background(Color.green)
            }
            .foregroundColor(Color.black)
            .padding(.horizontal)
            .background(Color.blue)
        }
    }
}

struct HomeCellView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCellView(chatItem: ChatItem(room_id: "1", room_name: "Nom du room", from_id: "2", to_id: "3", message_text: "Salut", date_send: Timestamp()))
    }
}
