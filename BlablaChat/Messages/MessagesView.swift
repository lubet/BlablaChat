//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//

import SwiftUI

@MainActor
final class MessagesViewModel: ObservableObject {

}

struct MessagesView: View {
    
    let oneContact: ContactModel
    
    var body: some View {
        Text("nom du conntact: \(oneContact.nom)")
    }
}

#Preview {
    MessagesView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
