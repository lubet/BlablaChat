//
//  HomeCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/02/2024.
//

import SwiftUI

struct HomeCellView: View {
    
    let conversation: Conversation
    
    var body: some View {
        NavigationLink(value: conversation.titre) {
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
                    Text("\(conversation.titre)")
                        .font(.headline)
                        .frame(width: 200, alignment: .leading)
                        .background(Color.green)
                    Text("\(conversation.last_message)")
                        .font(.headline)
                        .frame(width: 200,alignment: .leading)
                        .foregroundColor(Color.black)
                        .background(Color.gray)
                        .multilineTextAlignment(.leading)
                        
                }
                Text("\(conversation.last_date.displayFormat)")
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
        HomeCellView(conversation: Conversation(titre: "Richard", last_date: Date(), last_message: "Salut ca va la santé chez toi"))
    }
}
