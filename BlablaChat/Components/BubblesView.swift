//
//  BubblesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 11/01/2025.
//

import SwiftUI

struct BubblesView: View {
    
    let oneContact: ContactModel
    
    var body: some View {
        Text(oneContact.nom)
    }
}

#Preview {
    BubblesView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
