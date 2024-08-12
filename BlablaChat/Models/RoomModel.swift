//
//  RoomModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/08/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Room: Identifiable, Codable {
    let room_id: String
    let dateCreated: Timestamp
    let last_message: String
    let date_message: Timestamp
    let avatar_link: String
    
    var id: String {
        room_id
    }
    
    enum CodingKeys: String, CodingKey {
        case room_id
        case dateCreated = "date_created"
        case last_message
        case date_message
        case avatar_link
    }
}
