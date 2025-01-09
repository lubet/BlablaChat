//
//  UserRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import SwiftUI

struct UserRowView: View {
    
    let nomprenom: String
    
    var body: some View {
        HStack{
            Text(nomprenom)
            Spacer()
        }
    }
}

#Preview {
    UserRowView(nomprenom: "Leroy Marcel")
}
