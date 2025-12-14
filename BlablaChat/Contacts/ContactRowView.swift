//
//  UserRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import SwiftUI

struct ContactRowView: View {
    
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
    ContactsView()
}
