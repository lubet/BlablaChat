//
//  SwiftUIView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/01/2024.
//

import SwiftUI


final class MyMessageViewModel: ObservableObject {
    
    @Published private(set) var mesContacts: [Contact] = []
    
    func getContacts() async {
        self.mesContacts = await ContactManager.shared.getAllContacts()
    }
}


struct MyMessageView: View {
    
    @StateObject var viewModel = MyMessageViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.mesContacts) { oneContact in
                    Text(oneContact.nom)
                }
            }
        }
        .navigationTitle("Contacts")
        .task {
            await viewModel.getContacts()
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MyMessageView()
    }
}
