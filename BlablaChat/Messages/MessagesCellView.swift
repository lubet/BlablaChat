//
//  MessagesCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 12/03/2024.
//

import SwiftUI

struct MessageCellView: View {
    
    let messageItem: Message
    
    var body: some View {
        NavigationLink() {
            HStack {
                VStack(alignment: .leading){
                    Text("\(messageItem.message_text)")
                        .font(.headline)
                        .frame(width: 200,alignment: .leading)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                        .multilineTextAlignment(.leading)
                        
                }
                Text("\(messageItem.date_send)")
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

struct MessagesCellView_Previews: PreviewProvider {
    static var previews: some View {
        MessageCellView()
    }
}
