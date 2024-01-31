//
//  EssaiView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/01/2024.
//

import SwiftUI

final class EssaiViewViewModel: ObservableObject {
    
    @Published var chatText: String = ""
    
    func handleSend() {
        print("\(chatText)")
    }
}

struct EssaiView: View {
    
    @StateObject private var vm = EssaiViewViewModel()
    
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

struct EssaiView_Previews: PreviewProvider {
    static var previews: some View {
        EssaiView()
    }
}
