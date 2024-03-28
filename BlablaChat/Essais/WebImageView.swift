//
//  WebImageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 28/03/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct WebImageView: View {
    var body: some View {
        WebImage(url: URL(string: "https://picsum.photos/id/237/200/300"))
    }
}

struct WebImageView_Previews: PreviewProvider {
    static var previews: some View {
        WebImageView()
    }
}
