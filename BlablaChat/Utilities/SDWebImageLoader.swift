//
//  SDWebImageLoader.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/07/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct SDWebImageLoader: View {

    let url: String
    let size: CGFloat
    
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
            .cornerRadius(size)
            .overlay(RoundedRectangle(cornerRadius: 44)
            .stroke(Color.black, lineWidth: 0.5))
            // .background(Color(.red))
    }
}
