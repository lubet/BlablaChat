//
//  UsersCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 31/07/2024.
//

import SwiftUI

import SwiftUI

struct UsersCellView: View {
    
    let email: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(EmailShort(email: email))
                    .font(.headline)
                    .foregroundColor(.black)
                Text(email)
                    .font(.headline)
                    .foregroundColor(.black)
            }
//            .frame(width: 200, alignment: .center)
//            .padding()
        }
//        .padding(.horizontal,10)
    }
}

#Preview {
    UsersCellView(email: "maurice@test.com")
}

