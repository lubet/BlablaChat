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
    let salonId: String
    let fromId: String
    let texte: String
    let dateMessage: Timestamp

    var id: String {
        salonId
    }
    
    enum CodingKeys: String, CodingKey {
        case salonId = "salon_id"
        case fromId = "from_id"
        case texte
        case dateMessage = "date_message"
    }

}
