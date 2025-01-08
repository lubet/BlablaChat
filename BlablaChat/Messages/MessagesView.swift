//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//

import SwiftUI

@MainActor
final class MessagesViewModel: ObservableObject {

    func getAllMessages() {
        
    }
    
    func createMessage() {
        
    }
    
}

struct MessagesView: View {
    
    let email: String
    
    var body: some View {
        Text("email: \(email)")
    }
}

#Preview {
    MessagesView(email: "toto@test.com")
}
