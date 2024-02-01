//
//  SwiftUIView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/01/2024.
//

import SwiftUI

@MainActor
final class MyMessageViewModel: ObservableObject {
    
    // init() { }
    
    @Published private(set) var mesContacts: [Contact] = []

    func getContacts() async {
            // self.mesContacts = await ContactManager.shared.getAllContacts()
        self.mesContacts = await ContactManager.shared.mockContacts()
    }
}


struct MyMessageView: View {
    
    @StateObject var viewModel = MyMessageViewModel()
    
    @State private var searchText: String = ""
    
    @State private var messageTexte: String = ""
    
    var filteredContacts: [Contact] {
        guard !searchText.isEmpty else { return viewModel.mesContacts}
        return viewModel.mesContacts.filter { $0.nom.localizedCaseInsensitiveContains(searchText)}
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(filteredContacts) { oneContact in
                        // Text(oneContact.nom)
                        ContactCellView(lecontact: oneContact)
                    }
                }
            }
            bottomMessageBar
            .navigationTitle("Contacts")
        }
        .task { await viewModel.getContacts() }
        .searchable(text: $searchText, prompt: "Recherche d'un contact")
    }
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MyMessageView()
    }
}

// SEND
extension MyMessageView {
    private var bottomMessageBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                TextEditor(text: $messageTexte)
                    .opacity(messageTexte.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                // -> BubblesLog()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
