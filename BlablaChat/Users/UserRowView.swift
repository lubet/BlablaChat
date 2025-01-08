//
//  UserRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import SwiftUI

struct UserRowView: View {
    
    let nom: String
    
    var body: some View {
        HStack{
            Text(nom)
            Spacer()
        }
    }
}

#Preview {
    UserRowView(nom: "Maurice Leroy")
}
