//
//  Salons.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/12/2024.
//
// 

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Salons: Identifiable, Codable, Hashable {
    let salonId: String
    let dateCreated: Timestamp
    let lastMessage: String
    let sender: String
    
    var id: String {
        salonId
    }

    enum CodingKeys: String, CodingKey {
        case salonId = "salon_id"
        case dateCreated = "date_created"
        case lastMessage = "last_message"
        case sender = "user_id"
    }
}
