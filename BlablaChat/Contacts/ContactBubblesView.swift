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
    
    init() {}
    
    @Published private(set) var messagesBubble: [MessageBubble] = []
    
    // ScrollViewReader
    @Published private(set) var lastMessageId = ""
    
    // PhotoPicker
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published var param: [String:String] = ["":""]
    

    // Sauvegarde d'un message "Photo"
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }

        var selectedImage: UIImage? = nil

        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                
                if let uiImage = UIImage(data: data) {
                    selectedImage = uiImage

                    guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
                    let user_id = AuthUser.uid
                    
                    guard let para = param["room_id"] else {
                        print("setImage -Erreur param")
                        return }
                    
                    var room_id: String = ""
                    
                    if para == "" {
                        room_id = try await ContactsManager.shared.createRoom(name: para)
                    } else {
                        room_id = param["room_id"] ?? ""
                    }
                     
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

        // Sauvegarde d'un message "texte"
        func saveMessage(message_text: String, room_id: String) async throws {
            
            // TODO La gestion du nouveau contact (pas de users, room, member...)

            // Moi
            guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
            let user_id = AuthUser.uid
            
            // user "destinataire" to_id à trouver dans member
            let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id)
            
            // Sauvegarde du message "texte"
            try await ContactsManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: message_text, room_id: room_id, image_link: "")
            
            do {
                // Rafraichissement de la view actuelle
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
    
    // Get tous les messages d'un contact existant ou rien si le contact n'existe pas encore
    func getContactMesssages(email: String) async throws {
        
        // Moi
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = AuthUser.uid
        
        // Trouver dans users le contact_id à l'aide de son email
        var contact_id  = try await ContactsManager.shared.searchContact(email: email)
        
        if contact_id == "" {
            // créer le contact dans users et renvoyer son user_id
            contact_id = try await ContactsManager.shared.createUser(email: email)
        }
        
        // Recherche du couple user_id contact_id dans membre (il devrait en exister qu'une occurence ou pas)
        let room_id = try await ContactsManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
        
        if room_id == "" {
            // Pas encore de conversation
            param["room_id"] = ""
        } else {
            // Déjà une conversation (Room)
            param["room_id"] = room_id
            self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: user_id)
        }
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
        
        // Barre de saisie d'une message "texte" ou d'une "photo"
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
        .navigationTitle("Messages")
        
        // Chargement des messages du contact (si c'est un nouveau contact il n'y aura pas de messages).
        .task {
            do {
                try await viewModel.getContactMesssages(email: oneContact.email) // Nouveau ou ancien contact
            } catch {
                print("getContactMesssages - Error getting messages: \(error.localizedDescription)")
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
