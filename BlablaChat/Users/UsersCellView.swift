//
//  UsersCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 31/07/2024.
//

import SwiftUI

struct UsersCellView: View {
    
    let oneUser: DBUser
    
    var body: some View {
        HStack(alignment: .center) {
            SDWebImageLoader(url: oneUser.avatarLink!, size: 40)
            VStack(alignment: .leading, spacing: 5) {
                Text(EmailShort(email: oneUser.email!))
                    .font(.headline)
                    .foregroundColor(.black)
                Text(oneUser.email!)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.leading,20)
//            .frame(width: 200, alignment: .center)
//            .padding()
        }
//        .padding(.horizontal,10)
    }
}

//#Preview {
//    UsersCellView(email: "maurice@test.com")
//}

