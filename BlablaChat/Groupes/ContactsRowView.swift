//
//  ContactsRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 04/02/2026.
//

import SwiftUI

struct ContactsRowView: View {
    
    let oneContact: ContactModel
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: oneContact.isChecked ? "checkmark.circle" : "checkmark.circle")
                .padding(.trailing,10)
            Text(oneContact.nom)
                .padding(.trailing, 10)
            Text(oneContact.prenom)
        }
    }
}

#Preview {
    GroupesView()
}
