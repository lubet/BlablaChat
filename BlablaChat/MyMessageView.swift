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
    @Published private(set) var pairMembres: [Member] = []

    func getContacts() async {
            // self.mesContacts = await ContactManager.shared.getAllContacts()
        self.mesContacts = await ContactManager.shared.mockContacts()
    }
    
    func saveMessage(to_email: String, textMessage: String) async throws {
        let to_email = to_email
        let authUser = try? AuthManager.shared.getAuthenticatedUser()
        let from_email = authUser?.email ?? "n/a"
        self.pairMembres = try await ChatManager.shared.getMembers(from_email: from_email, to_email: to_email)
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
    
    func sendButtonPresses() async {
        if textIsCorrect() {
                try? await viewModel.saveMessage(to_email: filteredContacts[0].email, textMessage: "Hello")
        }
    }
    
    func textIsCorrect() -> Bool {
        if messageTexte.count < 3 {
            alertTitle = "Saisir un message d'au moins 3 caractères"
            showAlert.toggle()
            return false
        }
        if filteredContacts.count != 1 {
            alertTitle = "Veuillez selectionner un contact"
            showAlert.toggle()
            return false
        }
        return true
    }
    
    func getAlert() -> Alert {
        return Alert(title: Text(alertTitle))
    }
}
