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
    
    @Published var param: [String:Any] = [:] // pour récupérer le room_id utiliser dans setImage()
    
    // PhotoPicker
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    // PhotoPickeritem -> UIImage + Sauvegarde de l'image dans Storage
    private func setImage(from selection: PhotosPickerItem?) {
        
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage

                    guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
                    let user_id = AuthUser.uid
                    
                    guard let room_id = param["room_id"] else { return }
                    
                    let toId =  try await MessagesManager.shared.getToId(room_id: room_id as! String, user_id: user_id)

                    let lurl: URL
                    
                    guard let image = selectedImage else { return }
                    
                    // path = users/user_id/<nom du fichier.jpeg
                    let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: toId)
                    
                    lurl = try await StorageManager.shared.getUrlForImage(path: path)
                    
                    try await NewContactManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: "", room_id: room_id as! String, image_link: lurl.absoluteString)
                    
                    do {
                        // Rafraichissement de la view actuelle
                        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id as! String, user_id: AuthUser.uid)
                    } catch {
                        print("Error saveMessage: \(error.localizedDescription)")
                    }
                    
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
     
    // Sauvegarde du message "texte" (la photo est traitée à part - voir setImage())
    func saveMessage(message_text: String, room_id: String) async throws {

        // user "envoyeur"
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = AuthUser.uid
        
        // user "destinatire" to_id à trouver dans member
        let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id)
        
        // Sauvegarde du message "texte"
        try await NewContactManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: message_text, room_id: room_id, image_link: "")
        
        do {
            // Rafraichissement de la view actuelle
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
    let value: String // room_id
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.messagesBubble) { messageBubble in
                        if messageBubble.imageLink != "" {
                            MessagesCellPhoto(message: messageBubble)
                        } else {
                            MessagesCellView(message: messageBubble)
                        }
                    }
                }
                .padding(.top, 10)
                .background(.white)
            }
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
        .navigationTitle("Messages")
        .task {
            viewModel.param = ["room_id":value] // pour passer le room à la photo - voir setImage() en haut
            do {
                try await viewModel.getRoomMessages(room_id: value) // Tous les messages d'un room 
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
    
    // Sauvegarde du message "texte"
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
