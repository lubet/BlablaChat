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
    var send: Bool
    let fromId: String
    let texte: String
    let dateMessage: Timestamp
    let urlPhoto: String
    let toId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case salonId = "salon_id"
        case send = "send"
        case fromId = "from_id"
        case texte = "texte"
        case dateMessage = "date_message"
        case urlPhoto = "url_photo"
        case toId = "to_id"
    }
}
