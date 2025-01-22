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
    
    var body: some View {
        Text("\(message.fromId)")
    }
}

#Preview {
    MessageRowView(message: Messages(id: "", salonId: "12", fromId: "3FA...", texte: "Bonjour", dateMessage: Timestamp()))
}
