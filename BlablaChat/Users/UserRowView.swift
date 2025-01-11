//
//  UserRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import SwiftUI

struct UserRowView: View {
    
    let oneContact: ContactModel
    
    var body: some View {
        HStack(spacing: 10) {
            Text(oneContact.nom)
            Text(oneContact.prenom)
        }
        //.padding(.horizontal,20)
    }
}

#Preview {
    UserRowView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
