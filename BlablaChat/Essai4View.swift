//
//  Essai4View.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/01/2024.
//

import SwiftUI

struct Essai4View: View {
    var body: some View {
        VStack {
            Text("Emil")
            ScrollView {
                ForEach(1..<15) { message in
                    VStack {
                        HStack {
                            Text("Hello")
                        }
                    }
                }
            }
        }
    }
}

struct Essai4View_Previews: PreviewProvider {
    static var previews: some View {
        Essai4View()
    }
}
