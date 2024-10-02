//
//  MessageBigImage.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/10/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageBigImage: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let url = URL(string: "https://picsum.photos/400")
    
    let image: String
    
    var body: some View {
            
//        HStack() {
//            Button(action: {
//                presentationMode.wrappedValue.dismiss()
//            }, label: {
//                Image(systemName: "hand.point.left")
//                    .foregroundColor(.black)
//                    .font(.largeTitle)
//                    .padding(20)
//            })
//        }

            WebImage(url: URL(string: image))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture(count: 2) {
                    presentationMode.wrappedValue.dismiss()
                }
    }
}

//#Preview {
//    MessageBigImage(image: "https://picsum.photos/400")
//}
