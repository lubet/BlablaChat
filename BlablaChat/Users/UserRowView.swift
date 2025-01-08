//
//  UserRowView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 08/01/2025.
//

import SwiftUI

struct UserRowView: View {
    
    let email: String
    
    var body: some View {
        HStack{
            Text(email)
            Spacer()
        }
    }
}

#Preview {
    UserRowView(email: "mleroy@test.com")
}
