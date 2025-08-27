//
//  GroupRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 27/08/2025.
//

import SwiftUI

struct GroupRowView: View {
    
    let contact: Contact
    
    var body: some View {
        HStack {
            Image(systemName: contact.isChecked ? "checkmark.circle" : "circle")
            HStack {
                Text(contact.nom)
                    .font(.title2)
                Text(contact.prenom)
                    .font(.title2)
            }
            Spacer()
        }
    }
}

#Preview {
    GroupRowView(contact: Contact(nom: "Machpro", prenom: "Robert"))
}
