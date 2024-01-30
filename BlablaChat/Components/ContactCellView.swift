//
//  ContactCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/01/2024.
//

import SwiftUI

struct ContactCellView: View {
    
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(contact.nom)
                .font(.headline)
                .foregroundColor(.black)
            Text(contact.prenom)
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
    }
}

struct ContactCellView_Previews: PreviewProvider {
    static var previews: some View {
        ContactCellView(contact: Contact(id: "1", nom: "toto", prenom: "Maurice", email: "maurice@test.com"))
    }
}
