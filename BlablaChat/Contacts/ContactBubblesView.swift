//
//  ContactBubblesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 20/04/2024.
//
// Si le contact existe et si il a des messages
// 1) Affichage des messages existants pour ce contact
// 2) si nouveau contact affichage mais vide
// 3) Saisie d'un message ou d'une photo
// 4) Sauvegarde du message ou de la photo

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI


@MainActor
final class ContactBubblesViewModel: ObservableObject {
    
    @Published private(set) var messagesBubble: [MessageBubble] = []
    
    // ScrollViewReader
    @Published private(set) var lastMessageId = ""
    
    // PhotoPicker
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }

    private func setImage(from selection: PhotosPickerItem?) {
    }
    
    func getContactMesssages(email: String) async throws {
        // Trouver le user_id à l'aide de email
        var user_id = try await ContactsManager.shared.searchContact(email: "") // TODO
        if user_id == "" {
            // créer le contact et renvoyer le user_id
            user_id = try await ContactsManager.shared.createUser(email: "") // TODO
        }
        // Affichage des messages ou rien
        // Tous les messages ou rien
    }
}

// -----------------------------------------------------

struct ContactBubblesView: View {
    
    let oneContact: Contact
    
    @Binding var path: NavigationPath
    
    @StateObject var viewModel = ContactBubblesViewModel()
    
    @State private var messageText: String = ""
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 20) {
                    ForEach(viewModel.messagesBubble, id: \.id) { messageBubble in
                        if messageBubble.imageLink != "" {
                            MessagesCellPhoto(message: messageBubble)
                        } else {
                            MessagesCellView(message: messageBubble)
                        }
                    }
                    
                }
                .padding(.top,10)
                .background(.white)
                .onChange(of: viewModel.lastMessageId) { id in
                    withAnimation {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
        .navigationTitle("Messages")
        .task {
            do {
                try await viewModel.getContactMesssages(email: "") // Tous les messages d'un contact
            } catch {
                print("ContactBubblesView - Error getting messages: \(error.localizedDescription)")
            }
        }
    }
}

//struct ContactBubblesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactBubblesView()
//    }
//}

// Barre de saisie du message ---------------------------------------------------

extension ContactBubblesView {
    
    private var MessageBar: some View {
        HStack {
           
            // Affichage des photos
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Image(systemName: "photo")
                    .foregroundColor(Color.black)
            }
            
            // Saisie du message
            TextField("Message", text: $messageText, axis: .vertical)
                .foregroundColor(Color.black)
            
            // Envoi du message
            Image(systemName: "paperplane.circle")
                .padding()
                .offset(x:10)
                .foregroundColor(Color.blue)
                .opacity(messageText.isEmpty ? 0.0 : 1.0)
                .onTapGesture {
                    sendButton()
                }
        }
        .font(.headline)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.05))
        )
        .padding()
    }
    
    // Sauvegarde du message "texte"
    func sendButton() {
        if textIsCorrect() {
//            Task {
//                try? await viewModel.saveMessage(message_text: messageText, room_id: value.room_id)
//                messageText = ""
//            }
        }
    }
    
    func textIsCorrect() -> Bool {
        if messageText.count < 3 {
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
