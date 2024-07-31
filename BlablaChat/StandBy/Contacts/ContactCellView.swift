//
//  ContactCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/01/2024.
//
// CellView d'un contact

import SwiftUI

struct ContactCellView: View {
    
    let oneItem: ListeAllUsers
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(oneItem.nom)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(oneItem.email)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(width: 200, alignment: .center)
            .padding()
            // .background(Color.black.opacity(0.05))
        }
        .padding(.horizontal,10)
    }
}

struct ContactCellView_Previews: PreviewProvider {
    static var previews: some View {
        ContactCellView(oneItem: ListeAllUsers(nom: "toto", email: "maurice@test.com"))
    }
}
