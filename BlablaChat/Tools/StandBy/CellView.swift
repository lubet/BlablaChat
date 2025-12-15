//
//  CellView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 09/06/2024.
//

import SwiftUI

struct CellView: View {
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .padding(8)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color.black, lineWidth: 1))
                    
                VStack(alignment: .leading) {
                    Text("email")
                        .font(.system(size: 16, weight: .bold))
                    Text("message")
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                }
                Spacer()
                Text("22d")
                    .font(.system(size: 14, weight: .semibold))
            }
            Divider()
                .padding(.vertical,8)
        }.padding(.horizontal)
    }
}

#Preview {
    CellView()
}
