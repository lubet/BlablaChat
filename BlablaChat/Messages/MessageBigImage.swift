//
//  MessageBigImage.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/01/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageBigImage: View {
    @Environment(\.presentationMode) var presentationMode
    
    let urlImage: String
    
    var body: some View {
        WebImage(url: URL(string: urlImage))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture(count: 2) {
                presentationMode.wrappedValue.dismiss()
            }
    }
}

#Preview {
    MessageBigImage(urlImage: "https://picsum.photos/400")
}
