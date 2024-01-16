//
//  BubbleMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/01/2024.
//
// * Il me faut l'obj

import SwiftUI

struct BubbleMessageView: View {
    
    let message: Int
    let monUserId: String
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BubbleMessageView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleMessageView(message:123, monUserId: "456")
    }
}
