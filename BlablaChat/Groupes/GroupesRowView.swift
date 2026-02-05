//
//  ContactsRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 04/02/2026.
//

import SwiftUI

struct GroupesRowView: View {
    
    let oneContact: ContactModel
    
    var body: some View {
        HStack() {
            Image(systemName: oneContact.isChecked ? "checkmark.circle" : "circle")
                .padding(.trailing,10)
                .foregroundStyle(oneContact.isChecked ? Color.blue: Color.gray)
            Text(oneContact.nom)
                .padding(.trailing, 10)
            Text(oneContact.prenom)
            Spacer()
        }
        .font(.title2)
    }
}

#Preview {
    GroupesRowView(oneContact: ContactModel(nom: "Leroy", prenom: "Marcel", email: "mleroy@test.com",isChecked: false))
}
