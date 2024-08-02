//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/03/2024.
//
// Création d'un message de A pour B
// A la création du message:
//  créer deux enregs dans "members" (si n'existe pas) - un por A, un pour B avec le même numéro de room
//  création un enreg correspodant dans "rooms"
//  création un enreg dans "messages" avec le même numéro de room

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
                    
                    // Recherche de l'email dans "users"
                    var contact_id  = try await UsersManager.shared.searchContact(email: email)
                    
                    if contact_id == "" {

                        // créer user
                        contact_id = try await UsersManager.shared.createUser(email: email)
                        
                        // créer l'avatar
                        let mimage: UIImage = UIImage.init(systemName: "person.fill")!
                        let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: contact_id)
                        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
                        try await UsersManager.shared.updateImagePath(userId: contact_id, path: lurl.absoluteString) // maj Firestore

                        // créer room
                        let room_id = try await UsersManager.shared.createRoom(name: email, avatar_link: lurl.absoluteString)

                        // créer membre
                        try await UsersManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: contact_id)
                    }
                    
                    let room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
                    
                    // Recherche dans membre
                    guard let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id) else {
                        return
                    }

                    let lurl: URL
                    
                    guard let image = selectedImage else {
                        return
                    }
                    
                    // path = users/user_id/<nom du fichier.jpeg
                    let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: toId)
                     
                    lurl = try await StorageManager.shared.getUrlForImage(path: path)
                    
                    try await UsersManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: "", room_id: room_id, image_link: lurl.absoluteString)
                    
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
    func getRoomMessages(email: String) async throws {
        
        // Trouver dans "users" le contact_id à l'aide de son email
        let contact_id  = try await UsersManager.shared.searchContact(email: email)

        if contact_id != "" {

            guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
            let user_id = AuthUser.uid

            // Chercher le room_id du couple user_id/contact_id dans "members"
            let room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)

            if room_id != "" {
                self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: user_id)
                scrollViewReaderId()
            }
        }
    }
     
    // A la création du message:
    
    // L'auth et le selectioné sont déjà dans "users" car ce sont des authentifiés (automatiquement créer dans users)
    
    // Si il n'y pas de room existant dans "members" pour l'auth et le selectioné:
        // Création d'un enreg dans "rooms"
        // Création du message pour cette room
        // Création de deux enregs dans "members" un pour l'auth l'autre pour celui selectionné ave le room créer au début
    
    // Si il y a un room existant dans "members" pour l'auth et le selectionné:
       // Créer le message pour cette room
    
    func saveMessage(email: String, message_text: String) async throws {
        
        // Si il n'y pas de room existant dans "members" pour l'auth et le selectioné
        guard let AuthUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = AuthUser.uid

        // Chercher le user_id du selectionné avec son email dans "users"
        var select_id  = try await UsersManager.shared.searchContact(email: email)
        
        var room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: select_id)
        if room_id == "" {
            // Création d'un enreg "rooms"
            let room_id = try await UsersManager.shared.createRoom()
            //Création du message pour cette room
            try await UsersManager.shared.createMessage(from_id: user_id, to_id: select_id, message_text: message_text, room_id: room_id, image_link: "")

            
        }

        
        
        // Recherche de l'email dans "users"
        var contact_id  = try await UsersManager.shared.searchContact(email: email)
        
        // Pas présent dans "users" - on créet tout: users, rooms, members, messages) avec un avatar
        if contact_id == "" {
            
            // créer un user dans "users" (authentifié ou non)
            contact_id = try await UsersManager.shared.createUser(email: email)
            
            // créer l'avatar par défaut
            let mimage: UIImage = UIImage.init(systemName: "person.fill")!
            
            let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: contact_id)
                        
            let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
            
            try await UsersManager.shared.updateImagePath(userId: contact_id, path: lurl.absoluteString) // maj Firestore
            
            // créer "room"
            let room_id = try await UsersManager.shared.createRoom(name: email, avatar_link: lurl.absoluteString)
            
            // créer membre
            try await UsersManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: contact_id)
            
            // créer message
            try await UsersManager.shared.createMessage(from_id: user_id, to_id: contact_id, message_text: message_text, room_id: room_id, image_link: "")
            
        } else {
            // Présent dans "users"
             
            // Recherche du room_id dans member
            var room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)

            // SignUp. Après le login ils ne sont pas présent dans "rooms" ni dans "members"
            // C'est à l'envoi du premier message que se fait la création d'un item dans "rooms" et dans "members"
            if (room_id == "") {
                
                let memberDuo = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)

                if (memberDuo == "") {
                    
                    // Prendre l'avatar du SignUp dans "users"
                    let avatar = try await UsersManager.shared.getAvatar(contact_id: contact_id)
                                        
                    // Créer room
                    room_id = try await UsersManager.shared.createRoom(name: email, avatar_link: avatar)
                    
                    // Créer member
                    try await UsersManager.shared.createMembers(room_id: room_id, user_id: user_id, contact_id: contact_id)
               }
            }

            guard let toId =  try await MessagesManager.shared.getToId(room_id: room_id, user_id: user_id) else {
                return
            }
            
            try await UsersManager.shared.createMessage(from_id: user_id, to_id: toId, message_text: message_text, room_id: room_id, image_link: "")
        }

        // Rafraichissement de la view
        do {
            let room_id = try await UsersManager.shared.searchDuo(user_id: user_id, contact_id: contact_id)
            self.messagesBubble = try await MessagesManager.shared.getRoomMessages(room_id: room_id, user_id: AuthUser.uid)
            
            scrollViewReaderId()
            
        } catch {
            print("Error saveMessage: \(error)")
            return
        }
        
    }
    
    func scrollViewReaderId() {
        if let id = self.messagesBubble.last?.id {
            self.lastMessageId = id
        }
    }
}

// View ---------------------------------------------------

struct NewMessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
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
            viewModel.param = ["email": email] // pour passer le room à la photo - voir setImage() en haut
            do {
                try await viewModel.getRoomMessages(email: email) // Tous les messages relatif à un email
            } catch {
                print("getRoomMessages - Error getting documents: \(error)")
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
extension NewMessagesView {
    
    private var MessageBar: some View {
        HStack {
            // Selection de la photo
            PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                Image(systemName: "photo")
                    .foregroundColor(Color.black)
            }
            
            // Saisie du message
            TextField("Message", text: $messageText, axis: .vertical)
                .foregroundColor(Color.black)
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
