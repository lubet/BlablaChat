//
//  Essai3View.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/01/2024.
//
// ***** Firebase desactivé dans BlablaChatApp

import SwiftUI

struct Essai3View: View {
    
    @State var textMessageField: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<4) { num in
                    Spacer()
                    HStack{
                        Text("AAAAAAAA")
                    }
                    .padding()
                }
            }
            .background(Color.gray.opacity(0.3))
            TextField("Saisir", text: $textMessageField)
                .padding()
                .background(Color.gray.opacity(0.3).cornerRadius(10))
                .padding()
                .font(.headline)
        }
        .navigationTitle("Email")
    }
}

struct Essai3View_Previews: PreviewProvider {
    static var previews: some View {
        Essai3View()
    }
}
