//
//  BubblesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 18/02/2025.
//
// Dialogue du /user/salon selectionné dans LastMessageView
//

import SwiftUI
import PhotosUI

@MainActor
final class BubblesViewModel: ObservableObject {
    
    @AppStorage("currentUserId") var currentUserId: String?
    
    private var salonId: String = ""
    @Published var emailContact: String = ""
    
    private var didAppear: Bool = false // Listener sur les messages

    @Published var allMessages: [Messages] = []

    @Published private(set) var selectedImage: UIImage? = nil // UI image
    @Published var imageSelection: PhotosPickerItem? = nil  { // PhotosPicker image
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage =  UIImage(data: data) {
                    
                    // Sauvegarde dans Storage. TODO: par salon pour les messages-photos (toujours par user pour l'avatar)
                    let (path, _) = try await StorageManager.shared.saveImage(image: uiImage, salonId: salonId)

                    let lurl = try await StorageManager.shared.getUrlForImage(path: path)
                    
                    // Recherche du contact_id dans Salons
                    guard let contactID = try await MessagesManager.shared.getSalonContactId(salonId: salonId) else { print("newMessages-Pas de contactId"); return }
                    
                    // Création du message avec le n° de salon et le fromId égal au user
                    try await MessagesManager.shared.newMessage(salonId: salonId, fromId: userId, texte: "Photo", urlPhoto: lurl.absoluteString, toId: contactID)
                    
                    // Mettre à jour last_message dans Salons
                    try await MessagesManager.shared.majLastMessageSalons(salonId: salonId, lastMessage: lurl.absoluteString, userId: userId, contactId: contactID)
                    
                    return
                }
            }
        }
    }
    
    // Chargement des messages du salon concernant le user et le contact.
    func allUserSalonMessages() async throws {

        // userId
        guard let currentUserId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }
        
        // contactId
        let contactId =  try await UsersManager.shared.searchContact(email: emailContact) // dans la base Users

        // Si le contactId existe
        if contactId != "" {
            salonId = try await MessagesManager.shared.searchMembres(contactId: contactId, userId: currentUserId)
            allMessages = try await MessagesManager.shared.getMessages(salonId: salonId, currentUserId: currentUserId)
        } else {
            allMessages = []
        }
    }
    
    // Envoi d'un nouveau message à un nouveau contact ou à contact existant
    func newMessages(texteMessage: String) async throws {

        // user_id
        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        // contactId
        var contactId =  try await UsersManager.shared.searchContact(email: emailContact)
        if contactId == "" {
            contactId = try await UsersManager.shared.createUser(email: emailContact)
        }
        
        // salon_id
        salonId = try await MessagesManager.shared.searchMembres(contactId: contactId, userId: userId)
        if salonId == "" {
            salonId = try await MessagesManager.shared.newSalon(last_message: "")
            // Ajout du couple contact user à ce salon
            try await MessagesManager.shared.newMembres(salonId: salonId, contactId: contactId, userId: userId)
        }

        // Listener sur les messages
        if !didAppear {
            MessagesManager.shared.addlistenerMessages(salonId: salonId) { [weak self] messages in
                self?.allMessages = messages
            }
            didAppear = true
        }
        
        // Création du message avec le n° de salon et le fromId égal au user
        try await MessagesManager.shared.newMessage(salonId: salonId, fromId: userId, texte: texteMessage, urlPhoto: "", toId: contactId)
        
        // Mise à jour du texte du message dans le salon
        try await MessagesManager.shared.majLastMessageSalons(salonId: salonId, lastMessage: texteMessage, userId: userId, contactId: contactId)
        
    }
}

// View ------------------
struct BubblesView: View {
    
    let emailContact: String // <- ContactsView
    
    @StateObject var vm = BubblesViewModel()
    
    @State private var texteMessage: String = ""
    
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false

    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 20) {
                    ForEach(vm.allMessages) { message in
                        if message.texte == "Photo" {
                            MessageCellPhoto(message: message)
                        } else {
                            MessageRowView(message: message)
                        }
                    }
                }
            }
        }
        .navigationTitle("Bubbles")
        .onAppear {
            Task {
                vm.emailContact = emailContact
                try await vm.allUserSalonMessages()
                
            }
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
    }
}

// --------------------------------------
// Barre de saisie et d'envoie du message
extension BubblesView {
    
    private var MessageBar: some View {
        HStack {
            // Selection de la photo
            PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                Image(systemName: "photo")
                    .foregroundColor(Color.theme.textforeground)
            }
            
            // Saisie du message
            TextField("Message", text: $texteMessage, prompt: Text("Taper ici votre message").foregroundColor(Color.theme.textforeground), axis: .vertical)
                .foregroundColor(Color.theme.textforeground)
                .disableAutocorrection(true)

            // Envoi du message
            Image(systemName: "paperplane.circle")
                .padding()
                .offset(x:10)
                .foregroundColor(Color.theme.textforeground)
                .opacity(texteMessage.isEmpty ? 0.0 : 1.0)
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
            // path.removeAll() // back to LastMessagesView
            Task {
                try? await vm.newMessages(texteMessage: texteMessage)
                texteMessage = ""
            }
        }
    }
    
    func textIsCorrect() -> Bool {
        if texteMessage.count < 3 {
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


//#Preview {
//    BubblesView(email: "12@zut")
//}
