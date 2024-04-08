//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//
// Messages Bubble
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI

@MainActor
final class MessagesViewModel: ObservableObject {
    
    @Published private(set) var messagesBubble: [MessageBubble] = []
    
    // PhotoPicker
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    // PhotoPickeritem -> UIImage
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    return
                }
            }
        }
    }
    
    // Tous les messages d'un room
    func getRoomMessages(room_id: String) async throws {
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }

        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
    }
     
    // Sauvegarde du message avec ou sans photo
    func saveMessage(message_text: String, room_id: String) async throws {
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        
        let user_id = AuthUser.uid
        
        // Recherche du to_id dans member
        let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id)
        
        // Sauver l'image dans Storage
        if let image = selectedImage {

            let lurl: URL

            let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: toId)
            
            lurl = try await StorageManager.shared.getUrlForImage(path: path)
            
            try await NewContactManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: message_text, room_id: room_id, image_link: lurl.absoluteString)
        } else {
            try await NewContactManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: message_text, room_id: room_id, image_link: "")
       }
            
        do {
            // TODO prévoir image_link dans messageBubble et affichage avec sdWeb - gérér si pas d'image
            self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
        } catch {
            print("Error saveMessage: \(error.localizedDescription)")
        }
        
    }
}

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @State private var messageText: String = ""
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    // <- LastMessagesView
    let value: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.messagesBubble) { messageBubble in
                    MessagesCellView(message: messageBubble)
                }
            }
            .padding(.top, 10)
            .background(.white)
            
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
        .navigationTitle("Messages")
        .task {
            do {
                try await viewModel.getRoomMessages(room_id: value)
            } catch {
                print("RoomMessagesView - Error getting documents: \(error.localizedDescription)")
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(value: "123")
    }
}

// Barre de saisie du message
extension MessagesView {
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
    
    func saveImage() {
        Task {
            try? await viewModel.saveMessage(message_text: messageText, room_id: value)
        }
    }
    
    func sendButton() {
        if textIsCorrect() {
            Task {
                try? await viewModel.saveMessage(message_text: messageText, room_id: value)
            }
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
