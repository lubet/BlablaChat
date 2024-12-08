//
//  ContactRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/12/2024.
//

import SwiftUI

struct ContactRowView: View {
    
    let oneContact: ContactModel
    
    var body: some View {
        HStack {
            Text(oneContact.nom)
            Spacer()
        }
    }
}

struct ContactRowView_Previews: PreviewProvider {
    static var contact1 = ContactModel(nom: "nom", prenom: "prenom", emai: "email")
    
    static var previews: some View {
        ContactRowView(oneContact: contact1)
    }
}
