//
//  EssaiView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/01/2024.
//

import SwiftUI

struct EssaiView: View {
    var body: some View {
        NavigationView {
            NavigationLink(
                destination: Essai2View(userId: "123456"),
            label: {
                Text("zut")
            })
        }
    }
}

struct EssaiView_Previews: PreviewProvider {
    static var previews: some View {
        EssaiView()
    }
}
