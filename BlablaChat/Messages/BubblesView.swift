//
//  BubblesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 18/02/2025.
//
// Dialogue du /user/salon selectionné dans LastMessageView
//
// A l'envoie du message: je crée le salon, ses deux subUsers, le message

import SwiftUI
import PhotosUI

@MainActor
final class BubblesViewModel: ObservableObject {
    
    @AppStorage("currentUserId") var currentUserId: String?
    
    private var salonId: String = ""
    @Published var emailContact: String = ""
    
    private var didAppear: Bool = false // Listener sur les messages

    @Published var allMessages: [Messages] = []
    @Published var sortedMessages: [Messages] = []
    @Published private(set) var lastMessageId: String = ""

    @Published private(set) var selectedImage: UIImage? = nil // UI image
    @Published var imageSelection: PhotosPickerItem? = nil  { // PhotosPicker image
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    // Tri des messages
    func sortAllMessages() {
        sortedMessages = allMessages.sorted {( message1, message2 ) -> Bool in
            return message1.dateSort < message2.dateSort
        }
        if let id = sortedMessages.last?.id {
            lastMessageId = id
        }
    }
    
    // Maj Send pour le listener
    func listenerMessages() {
        var tempMessages: [Messages] = []
        
        for var message in allMessages {
            if message.receiver == currentUserId {
                message.send = false
            } else {
                message.send = true
            }
            tempMessages.append(message)
        }
        sortedMessages = tempMessages.sorted {( message1, message2 ) -> Bool in
            return message1.dateSort < message2.dateSort}
        if let id = sortedMessages.last?.id {
            lastMessageId = id
        }
     }
    
    // Sauvegarde de l'image
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
                    guard let contactID = try await SalonsManager.shared.getSalonContactId(salonId: salonId) else { print("newMessages-Pas de contactId"); return }
                    
                    // Listener sur les messages
                    if !didAppear {
                        MessagesManager.shared.addlistenerMessages(salonId: salonId) { [weak self] messages in
                            self?.allMessages = messages
                            self?.listenerMessages()
                        }
                        didAppear = true
                    }
                    
                    // Création du message avec le n° de salon et le fromId égal au user
                    try await MessagesManager.shared.newMessage(salonId: salonId, receiver: userId, texte: "Photo", urlPhoto: lurl.absoluteString, sender: contactID)
                    
                    // Mettre à jour last_message dans Salons
                    try await SalonsManager.shared.majLastMessageSalons(salonId: salonId, lastMessage: lurl.absoluteString, receiver: contactID)
                    
                    return
                }
            }
        }
    }
    
    // Chargement des messages du salon concernant le user et le contact.
    func allUserSalonMessages(oneContact: ContactModel) async throws {
        
        guard let currentUserId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        // Recherche du contact dans la base Users
        let contactId =  try await UsersManager.shared.searchContact(email: oneContact.email)
        
        // TODO pour la gestion d'un groupe (n membres d'un salon) - remplace le code ci-dessous:
        // Chercher si un salon existe pour uniquement les membres qui ont été selectionnés dans la View (à faire).
        
        // Si le contact existe
        if contactId != "" {
            // Retourne le salonId commun au contact et au current user seuls
            
            // TODO retourne "" -> pas de salon ce qui est normal car c'est un nouveau contact
            salonId = try await MessagesManager.shared.getSalonId(currentId: currentUserId, contactId: contactId)
            
            // Les derniers messages du salon et maj du Send
            allMessages = try await MessagesManager.shared.getMessages(salonId: salonId, currentUserId: currentUserId)
            
            sortAllMessages()
            
        } else {
            allMessages = []
        }
    }
    
    // Envoi d'un nouveau message à un nouveau contact ou à contact existant
    func newMessages(texteMessage: String, nom: String, prenom: String, emailContact: String) async throws {

        // user_id
        guard let currentUserId = currentUserId else { print("**** allUserSalonMessages() - Pas de currentUserId"); return }

        // Recherche du contactId dans Users
        var contactId =  try await UsersManager.shared.searchContact(email: emailContact)
        if contactId == "" {
            contactId = try await UsersManager.shared.createUser(email: emailContact, nom: nom, prenom: prenom)
        }
        
        // Recherche dans subUsers du salonId commun au currentId et au contactId
        salonId = try await MessagesManager.shared.getSalonId(currentId: currentUserId, contactId: contactId)
        
        if salonId == "" {
            salonId = try await SalonsManager.shared.newSalon(last_message: "", receiver: contactId)
            
            // Ajout du couple contact currentuser à la sous-collection subUsers de ce salon
            try await MessagesManager.shared.newTwoSubUsers(salonId: salonId, currendId: currentUserId, contactId: contactId)
        }

        // Listener sur les messages
        if !didAppear {
            MessagesManager.shared.addlistenerMessages(salonId: salonId) { [weak self] messages in
                self?.allMessages = messages
                self?.listenerMessages()
            }
            didAppear = true
        }
        
        // Création du message avec le n° de salon et le fromId égal au user
        try await MessagesManager.shared.newMessage(salonId: salonId, receiver: contactId, texte: texteMessage, urlPhoto: "", sender: currentUserId)
        
        // Mise à jour du texte du message dans le salon
        try await SalonsManager.shared.majLastMessageSalons(salonId: salonId, lastMessage: texteMessage, receiver: contactId)
    }
}

// View ------------------
struct BubblesView: View {
    
    @Environment(\.router) var router

    let oneContact: ContactModel
    
    @StateObject var vm = BubblesViewModel()
    
    @State private var texteMessage: String = ""
    
    @State var alertTitle: String = ""
    @State var showAlert: Bool = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(vm.sortedMessages) { message in
                        if message.texte == "Photo" {
                            MessageCellPhoto(message: message)
                        } else {
                            MessageRowView(message: message)
                        }
                    }
                }
            }
            .onChange(of: vm.lastMessageId) { oldValue, newValue in
                proxy.scrollTo(newValue, anchor: .bottom)
            }
        }
        .navigationTitle("Bubbles")
        .onAppear {
            Task {
                try await vm.allUserSalonMessages(oneContact: oneContact)
            }
        }
        .onDisappear {
            router.dismissScreenStack()
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
            .padding(.leading,10)
            
            // Saisie du message
            TextField("Message", text: $texteMessage, prompt: Text("Taper ici votre message").foregroundColor(Color.theme.textforeground), axis: .vertical)
                .foregroundColor(Color.theme.textforeground)
                .disableAutocorrection(true)

            // Envoi du message
            Image(systemName: "paperplane.circle")
                .padding()
                .padding(.trailing,10)
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
                try? await vm.newMessages(texteMessage: texteMessage, nom: oneContact.nom, prenom: oneContact.prenom, emailContact: oneContact.email)
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
