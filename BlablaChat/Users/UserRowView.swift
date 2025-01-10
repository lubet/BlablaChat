//
//  UserRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import SwiftUI

struct UserRowView: View {
    
    let contact: ContactModel
    
    var body: some View {
        HStack(spacing: 10) {
            Text(contact.nom)
            Text(contact.prenom)
        }
    }
}

#Preview {
    UserRowView(contact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
