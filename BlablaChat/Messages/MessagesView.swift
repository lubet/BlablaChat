//
//  NewMessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//
// L'email du destinataire est transmis par "UsersView" (call back)
// Liste des messages du destinataire (bubble)
// Si pas de "room"
//      création d'un room
//      création d'un enreg membre envoyeur/destinataire/room_id
// Création du message texte ou photo avec un room_id (créer ci-dessus ou existant)

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import PhotosUI

@MainActor
final class NewMessagesViewModel: ObservableObject {
    
    @Published private(set) var messagesBubble: [MessageBubble] = []
    
    @Published var param: [String:String] = [:] // pour récupérer le room_id utiliser dans setImage()
    
    // ScrollViewReader
    @Published private(set) var lastMessageId = ""
    
    // PhotoPicker
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            guard let email = param["email"] else {
                print("Pas d'email pour la photo")
                return
            }
            setImage(from: imageSelection, email: email)
        }
    }
    
    // TODO Image pour un existant et un non existant
    private func setImage(from selection: PhotosPickerItem?, email: String) {
        
        guard let selection else { return }

        var selectedImage: UIImage? = nil

        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage

                    guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
                    let user_id = AuthUser.uid
                    
                    // Recherche du select_id dans "users" à l'aide de l'email (existe forcemment)
                    let select_id  = try await UsersManager.shared.searchContact(email: email)
                    
                    // Recherche du room_id dans "members" avec le user_id et le select_id
                    var room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: select_id)
                    
                    if (room_id) == "" {
                        
                        // Recherche de l'avatar dans "users" avec l'email
                        let avatarLink = try await LastMessagesManager.shared.getAvatarLink(email: email)
                        
                        // Création d'un enreg "rooms" avec le "user_id" de son créateur
                        room_id = try await UsersManager.shared.createRoom(avatar_link: avatarLink)

                        // Création d'un enreg dans "members"
                        try await UsersManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: select_id)
                    }
                    
                    // Sauvegarde de l'image
                    let lurl: URL
                    guard let image = selectedImage else { return }
                    
                    // path = users/user_id/<nom du fichier.jpeg
                    let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: user_id)

                    lurl = try await StorageManager.shared.getUrlForImage(path: path)
                    
                    // Dans "members", raméne les deux user_id ayant le même room_id
                    // let (user_id1, user_id2) = try await LastMessagesManager.shared.getFromId(room_id: room_id)
                    
                    try await UsersManager.shared.createMessage(from_id: user_id, message_text: "", room_id: room_id, image_link: lurl.absoluteString, to_id: select_id)
                    
                    do {
                        // Rafraichissement de la view actuelle
                        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
                        
                        scrollViewReaderId()
                        
                    } catch {
                        print("Error saveMessage: \(error)")
                        return
                    }
                    
                }
            }
        }
    }
        
    
    // Tous les messages d'un contact
    // Il me faut le user_id et le select_id
    // searchDuo
    func getRoomMessages(email: String) async throws {
        
        // user_id
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else {
            return
        }
        let user_id = AuthUser.uid
        
        // Recherche du selected_id avec son email dans "members"
        let selected_id = try await UsersManager.shared.searchContact(email: email)
        
        // Recherche du room_id dans "members" avec le from_id et le to_id
        let room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: selected_id)
        
        if room_id != "" {
            self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: user_id)
            scrollViewReaderId()
        } else {
            print("getRoomMessages - Pas de room_id")
        }
    }
     
    // Sauvegarde du nouveau message avec le FCMtoken du destinaire
    func saveMessage(email: String, message_text: String) async throws {
        
        // user_id (auth)
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = AuthUser.uid

        // Recherche du select_id dans la base "users" avec l'email du select
        let select_id = try await UsersManager.shared.searchContact(email: email)
        
        // Recherche du room_id dans "members" avec le user_id et le select_id
        var room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: select_id)
        
        // Pas de room existant
        if (room_id) == "" {
            
            // Recherche de l'avatar dans "users" avec l'email
            let avatarLink = try await LastMessagesManager.shared.getAvatarLink(email: email)
            
            // Création d'un enreg "rooms" avec le "user_id" de son créateur
            room_id = try await UsersManager.shared.createRoom(avatar_link: avatarLink)
            
            // Création d'un enreg dans "members" avec le user_id, le select_id et le room_id si il n'existe pas déjà
            let dejaMembre = try await UsersManager.shared.dejaMembre(room_id: room_id, user_id: user_id, contact_id: select_id)
            
            if !dejaMembre {
                try await UsersManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: select_id)
            }
        }

        // Message
        try await UsersManager.shared.createMessage(from_id: user_id, message_text: message_text, room_id: room_id,
                                                    image_link: "", to_id: select_id)
        
        // Rafraichissement de la view bubble
        self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: user_id)
        scrollViewReaderId()
    }
    
    func scrollViewReaderId() {
        if let id = self.messagesBubble.last?.id {
            self.lastMessageId = id
        }
    }
}

// View ---------------------------------------------------

struct NewMessagesView: View {
    @StateObject private var viewModel = NewMessagesViewModel()
    @State private var messageText: String = ""
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false
    
    // from LastMessagesView:
    @Binding var path:[LastMessage] // Uniquement pour revenir au NavigationStack de LastMessagesView
    
    let email: String // vient de LastMessagesView
    
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
                
                .onChange(of: viewModel.lastMessageId) { id, _ in
                    withAnimation {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
                
                // Avant iOS 17
//                .onChange(of: viewModel.lastMessageId) { id in
//                    withAnimation {
//                        proxy.scrollTo(id, anchor: .bottom)
//                    }
//                }
            }
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
        .navigationTitle("NewMessagesView 📝")
        .task {
            viewModel.param = ["email": email] // pour passer le room à la photo - voir setImage() en haut
            do {
                try await viewModel.getRoomMessages(email: email) // Tous les messages relatif à un email
            } catch {
                print("getRoomMessages - Error getting documents: \(error)")
            }
        }
    }
}

// Barre de saisie du message ---------------------------------------------------
extension NewMessagesView {
    
    private var MessageBar: some View {
        HStack {
            // Selection de la photo
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Image(systemName: "photo")
                    //.foregroundColor(Color.black)
            }
            
            // Saisie du message
            TextField("Message", text: $messageText, axis: .vertical)
                .disableAutocorrection(true)
            
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
            path.removeAll() // back to LastMessagesView
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
