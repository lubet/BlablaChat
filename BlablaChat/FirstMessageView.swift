//
//  FirstMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/01/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift



struct FirstMessageView: View {
    @State var new_message: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextField("Nouveau message", text: $new_message)
                    .padding(20)
                    .background(Color.gray.opacity(0.3).cornerRadius(10))
                    .foregroundColor(.black)
                
            }
            .padding()
            .navigationTitle("Nouveau message")
        }
    }
}

struct FirstMessageView_Previews: PreviewProvider {
    static var previews: some View {
        FirstMessageView()
    }
}
