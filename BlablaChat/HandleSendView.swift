//
//  FirstMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/01/2024.
//

import SwiftUI

final class HandleSendViewModel: ObservableObject {
    
    @Published var chatText: String = ""
    
    func handleSend() {
        print("\(chatText)")
    }
}

struct HandleSendView: View {
    
    let chatUser: DBUser?
    
    @StateObject private var vm = HandleSendViewModel()
    
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

struct HandleSendView_Previews: PreviewProvider {
    static var previews: some View {
        HandleSendView(chatUser: DBUser(userId: "123456", email: "toto@test.com", dateCreated: Date(), imageLink: "https://"))
    }
}
