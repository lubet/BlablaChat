//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//
// Messages Bubbles des conversations en cours (lastMessages)
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI

@MainActor
final class MessagesViewModel: ObservableObject {
    
    @Published private(set) var messagesBubble: [MessageBubble] = []
    
    @Published var param: [String:String] = [:] // pour récupérer le room_id utiliser dans setImage()
    
    // ScrollViewReader
    @Published private(set) var lastMessageId = ""
    
    // PhotoPicker
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    // PhotoPickeritem -> UIImage + Sauvegarde de l'image dans Storage
    private func setImage(from selection: PhotosPickerItem?) {
        
        guard let selection else { return }

        var selectedImage: UIImage? = nil

        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage

                    guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
                    let user_id = AuthUser.uid
                    
                    guard let room_id = param["room_id"] else { return }
                    
                    let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id)

                    let lurl: URL
                    
                    guard let image = selectedImage else { return }
                    
                    // path = users/user_id/<nom du fichier.jpeg
                    let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: toId)
                    
                    lurl = try await StorageManager.shared.getUrlForImage(path: path)
                    
                    try await ContactsManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: "", room_id: room_id, image_link: lurl.absoluteString)
                    
                    do {
                        // Rafraichissement de la view actuelle
                        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
                        
                        scrollViewReaderId()
                        
                    } catch {
                        print("Error saveMessage: \(error.localizedDescription)")
                        return
                    }
                    
                }
            }
        }
    }
        
    
    // Afichage du dialogue ou blanc si le dialoque n'existe pas encore
    func getRoomMessages(email: String) async throws {
        // Moi
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = AuthUser.uid
        
        // Trouver dans "users" le contact_id à l'aide de son email
        let contact_id  = try await ContactsManager.shared.searchContact(email: email)
        
        if contact_id != "" {
            // Chercher le room_id du couple user_id/contact_id dans "members"
            let room_id = try await ContactsManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
            if room_id == "" {
                param["room_id"] = ""
            } else {
                param["room_id"] = room_id
                self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: user_id)
                
                scrollViewReaderId()
            }
        } else {
            param["room_id"] = ""
        }
    }
     
    // Création du message texte
    // 1) le contact n'existe pas
    // 2) le contact existe.ok.
    func saveMessage(email: String, message_text: String) async throws {
        
        // Moi
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = AuthUser.uid
        
        var contact_id  = try await ContactsManager.shared.searchContact(email: email)
        
        if contact_id == "" { // le contact n'existe pas dans "users"
            
            print("saveMessage - le contact n'existe pas dans \"users\"")
            
            // créer "users"
            contact_id = try await ContactsManager.shared.createUser(email: email)
            print("contact_id: \(contact_id)")
            
            // créer "room"
            let room_id = try await ContactsManager.shared.createRoom(name: email)
            print("room_id: \(room_id)")
            
            // créer membre
            try await ContactsManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: contact_id)
            print("createMembers")
            
            // créer message
            try await ContactsManager.shared.createMessage(from_id: user_id, to_id: contact_id, message_text: message_text, room_id: room_id, image_link: "")
            print("createMessage")
            
        } else {

            print("saveMessage - le contact existe dans \"users\"")
            
            // le contact existe dans "users"
            let room_id = try await ContactsManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)

            let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id)
            
            try await ContactsManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: message_text, room_id: room_id, image_link: "")
        }

        // Rafraichissement de la view
        do {
            let room_id = try await ContactsManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
            self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
            
            scrollViewReaderId()
            
        } catch {
            print("Error saveMessage: \(error.localizedDescription)")
            return
        }
        
    }
    
    func scrollViewReaderId() {
        if let id = self.messagesBubble.last?.id {
            self.lastMessageId = id
            print("id: \(id)")
        }
    }
}

// View ---------------------------------------------------

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @State private var messageText: String = ""
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    // from LastMessagesView:
    @Binding var path:[LastMessage] // Uniquement pour le "Back to root" automatique
    let email: String // <- LastMessagesView <- ContactsView
    
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
                .padding(.top, 10)
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
        .navigationTitle("MessagesView")
        .task {
            viewModel.param = ["email":email] // pour passer le room à la photo - voir setImage() en haut
            do {
                try await viewModel.getRoomMessages(email: email) // Tous les messages relatif à un email
            } catch {
                print("getRoomMessages - Error getting documents: \(error.localizedDescription)")
            }
        }
    }
}

//struct MessagesView_Previews: PreviewProvider {
//    static var previews: some View {
////        MessagesView(email: "toto")
////        MessagesView(value: LastMessage(room_id: "1", room_name: "toto", room_date: timeStampToString(dateMessage: Timestamp()), message_texte: "Hello", message_date: timeStampToString(dateMessage: Timestamp()), message_from: "tutu", message_to: "toto"))
////    }
//}

// Barre de saisie du message ---------------------------------------------------
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
            path.removeAll() // back to root
            Task {
                try? await viewModel.saveMessage(email: email, message_text: messageText)
                messageText = ""
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
