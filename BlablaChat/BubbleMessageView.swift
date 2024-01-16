//
//  BubbleMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/01/2024.
//

import SwiftUI

struct BubbleMessageView: View {
    
    let item: Int
    let userId: String
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BubbleMessageView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleMessageView(item:123, userId: "456")
    }
}
