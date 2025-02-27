//
//  MessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/01/2025.
//
// Dialogue du /user/salon selectionné dans LastMessageView
//

import SwiftUI
import PhotosUI

@MainActor
final class MessagesViewModel: ObservableObject {
    
    @AppStorage("currentUserId") var currentUserId: String?

    private var salonId: String = ""
    private var didAppear: Bool = false
    
    @Published var allMessages: [Messages] = []
    @Published private(set) var selectedImage: UIImage? = nil // UI image
    @Published var imageSelection: PhotosPickerItem? = nil  { // PhotosPicker image
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiImage =  UIImage(data: data) {
                    // selectedImage = uiImage
                    
                    guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

                    // Sauvegarde dans Storage. TODO: par salon pour les messages-photos (toujours par user pour l'avatar)
                    let (path, _) = try await StorageManager.shared.saveImage(image: uiImage, salonId: salonId)

                    let lurl = try await StorageManager.shared.getUrlForImage(path: path)
                    
                    // Création du message avec le n° de salon et le fromId égal au user
                    try await MessagesManager.shared.newMessage(salonId: salonId, fromId: userId, texte: "Photo", urlPhoto: lurl.absoluteString)
                    
                    // Mettre à jour last_message dans Salons
                    try await MessagesManager.shared.majLastMessageSalons(salonId: salonId, lastMessage: lurl.absoluteString)
                    
                    return
                }
            }
        }
    }
    
    
    // Messages du user/salon
    func allMyMessages(oneContact: ContactModel) async throws {
        
        // user
        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        // Recherche du contact dans "Users" avec email
        var contactId =  try? await UsersManager.shared.searchContact(email: oneContact.email)
        
        // Création du contact dans "Users" si pas présent
        if contactId == "" {
            contactId = try await UsersManager.shared.createUser(email: oneContact.email)
        }

        guard let contactId else { print("MessagesViewModel: pas de contactId"); return }
        
        // Recherche du salon_id du couple contact user
        salonId = try await MessagesManager.shared.searchMembres(contactId: contactId, userId: userId)
        
        // Si pas présent création d'un salon
        if salonId == "" {
            salonId = try await MessagesManager.shared.newSalon(last_message: "", contactId: contactId)
            // Ajout du couple contact user à ce salon
            try await MessagesManager.shared.newMembres(salonId: salonId, contactId: contactId, userId: userId)
        }

        // Tous les messages du salon
        allMessages = try await MessagesManager.shared.getMessages(salonId: salonId)

        // Listener sur les messages
//        if !didAppear {
//            MessagesManager.shared.addlistenerMessages(salonId: salonId) { [weak self] messages in
//                self?.allMessages = messages
//            }
//            didAppear = true
//        }
        
    }
    
    // Création du message
    func newMessages(texteMessage: String) async throws {

        guard let userId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        // Création du message avec le n° de salon et le fromId égal au user
        try await MessagesManager.shared.newMessage(salonId: salonId, fromId: userId, texte: texteMessage, urlPhoto: "")
        
        // Mettre à jour last_message dans Salons
        try await MessagesManager.shared.majLastMessageSalons(salonId: salonId, lastMessage: texteMessage)
        
    }
}

struct MessagesView: View {
    let oneContact: ContactModel // <- ContactsView
    
    @StateObject var vm = MessagesViewModel()
    
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
        .onAppear {
            Task {
                try await vm.allMyMessages(oneContact: oneContact)
                
            }
        }
        MessageBar
            .alert(isPresented: $showAlert) {
                getAlert()
            }
    }
}

// Barre de saisie et d'envoie du message
extension MessagesView {
    
    private var MessageBar: some View {
        HStack {
            // Selection de la photo
            PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                Image(systemName: "photo")
                    //.foregroundColor(Color.black)
            }
            
            // Saisie du message
            TextField("Message", text: $texteMessage, axis: .vertical)
                .disableAutocorrection(true)
            
            // Envoi du message
            Image(systemName: "paperplane.circle")
                .padding()
                .offset(x:10)
                .foregroundColor(Color.blue)
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


#Preview {
    MessagesView(oneContact: ContactModel(prenom: "Marcel", nom: "Leroy", email: "mleroy@test.com"))
}
