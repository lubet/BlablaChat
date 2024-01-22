//
//  FirstMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/01/2024.
//

import SwiftUI

final class FirstMessageViewModel: ObservableObject {
    
    @Published var chatText: String = ""
    
    func handleSend() {
        print("message: \(chatText)")
    }
}

struct FirstMessageView: View {
    
    let chatUser: DBUser?
    
    @StateObject private var vm = FirstMessageViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    TextEditor(text: $vm.chatText)
                        .frame(height: 60)
                         .foregroundColor(.black)
                         .cornerRadius(20)
                         .background(Color.white)
                    Button {
                        vm.handleSend()
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
        FirstMessageView(chatUser: DBUser(userId: "123", email: "tyty@test.com", dateCreated: Date(), imageLink: "htts/"))
    }
}
