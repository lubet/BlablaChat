//
//  FirstMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/01/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift


@MainActor
final class FirstMessageViewModel: ObservableObject {
    
    @Published var first_message: String = ""

    func firstMessage(message: String) {
        ChatManager.shared.addChat(title: "Un titre", last_message: "Hello")
    }
}

struct FirstMessageView: View {
    
//    let sender : String = "1234"
//    let receiver: String = "5678"
    
    @StateObject private var vm = FirstMessageViewModel()
    @State var message: String
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    TextField("Nouveau message", text: $message)
                        .frame(height: 60)
                         .foregroundColor(.black)
                         .cornerRadius(20)
                         .background(Color.white)
                    Button {
                        print("message:\(message)")
                        vm.firstMessage(message: message)
                    } label: {
                        Image(systemName: "paperplane")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .navigationTitle("Nouveau message")
            .background(Color.gray.opacity(0.3).cornerRadius(10))
        }
    }
}

struct FirstMessageView_Previews: PreviewProvider {
    static var previews: some View {
        FirstMessageView(message: "Hello les amis")
    }
}
