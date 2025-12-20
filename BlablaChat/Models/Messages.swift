//
//  MessageModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 24/12/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Messages: Identifiable, Codable {
    let id: String
    let salonId: String
    var send: Bool // Utilisé uniquement pour l'affichage dans BubblesView
    let receiver: String
    let texte: String
    let dateMessage: Timestamp // date Firebase
    let urlPhoto: String
    let sender: String
    let dateSort: Date // date Swift pour le tri
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case salonId = "salon_id"
        case send = "send"
        case receiver = "receiver"
        case texte = "texte"
        case dateMessage = "date_message"
        case urlPhoto = "url_photo"
        case sender = "sender"
        case dateSort = "date_sort"
    }
}
