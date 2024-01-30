//
//  ContactCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/01/2024.
//

import SwiftUI

struct ContactCellView: View {
    
    let lecontact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lecontact.nom)
                .font(.headline)
                .foregroundColor(.black)
            Text(lecontact.email)
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
        ContactCellView(lecontact: Contact(id: "1", nom: "toto", email: "maurice@test.com"))
    }
}
