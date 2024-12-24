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
            SDWebImageLoader(url: oneUser.avatarLink!, size: 40) // TOD penser à récupérer ContactsManager
            VStack(alignment: .leading, spacing: 5) {
                Text(EmailShort(email: oneUser.email!))
                    .font(.headline)
                Text(oneUser.email!)
                    .font(.headline)
            }
            .padding(.leading,20)
        }
    }
}

