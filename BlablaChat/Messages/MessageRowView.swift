//
//  MessageRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 20/01/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MessageRowView: View {
    
    let message: Messages
    @State private var showTime: Bool = false
    
    var body: some View {
        VStack(alignment: message.send ? .leading : .trailing) {
            HStack {
                Text(message.texte)
                    .padding()
                    .background(message.send ? Color("Gris") : Color("BleuMauve"))
                    .cornerRadius(30)
                    .foregroundColor(Color.black)
            }
            .frame(maxWidth: 300, alignment: message.send ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
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
    MessageRowView(message: Messages(id: "", salonId: "12", send: true, fromId: "3FA...", texte: "Bonjour", dateMessage: Timestamp()))
}
