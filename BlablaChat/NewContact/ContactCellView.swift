//
//  ContactCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/01/2024.
//
// CellView d'un contact

import SwiftUI

struct ContactCellView: View {
    
    let lecontact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack {
                Text(lecontact.nom)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(lecontact.email)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            // .background(Color.black.opacity(0.05))
        }
        .padding(.horizontal,10)
    }
}

struct ContactCellView_Previews: PreviewProvider {
    static var previews: some View {
        ContactCellView(lecontact: Contact(nom: "toto", email: "maurice@test.com"))
    }
}
