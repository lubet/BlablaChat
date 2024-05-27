//
//  NewMessageCellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/01/2024.
//

import SwiftUI

struct NewMessageCellView: View {
    
    let user: DBUser // param de NewMessageView
    
    var body: some View {
            HStack(spacing: 20) {
                if let url = user.avatarLink {
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(RoundedRectangle(cornerRadius: 50)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                    } placeholder: {
                        ProgressView()
                            .frame(width: 40, height: 40)
                    }
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 70))
                        .padding()
                        .foregroundColor(Color(.label))
                        .clipShape(Circle())

                }
                Text(user.email ?? "")
                Spacer()
            } .padding(.horizontal)
            Divider()
                .padding(.vertical, 8)
    }
}

struct NewMessageCellView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageCellView(user: DBUser(userId: "123456", email: "trte@test.com", dateCreated: Date(),avatarLink: nil))
    }
}
