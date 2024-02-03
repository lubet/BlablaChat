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
    
    func saveMessage(toId: String, textMessage: String) {
//        let authUser = try? AuthManager.shared.getAuthenticatedUser()
//        let fromId = authUser?.uid
        print("\(toId)")
        print("\(textMessage)")
    }
}


struct MyMessageView: View {
    
    @StateObject var viewModel = MyMessageViewModel()
    
    @State private var searchText: String = ""
    
    @State private var messageTexte: String = ""
    
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
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
            .alert(isPresented: $showAlert) {
                getAlert()
            }
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

// Barre de saisie et d'envoie du message
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
                sendButtonPresses()
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
    
    func sendButtonPresses() {
        if textIsCorrect() {
            // Sauvegarde du message en base fromId, ToId, Chat
            let nbSelectedContact = filteredContacts.count
            if nbSelectedContact == 1 {
                viewModel.saveMessage(toId: "123456", textMessage: "Hello")
            }
        }
    }
    
    func textIsCorrect() -> Bool {
        if messageTexte.count < 3 {
            alertTitle = "Saisir un message d'au moins 3 caractères"
            showAlert.toggle()
            return false
        }
        return true
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle))
    }
}
