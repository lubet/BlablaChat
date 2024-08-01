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
    let room_name: String
    let dateCreated: Timestamp
    let last_message: String
    let date_message: Timestamp
    let user_id: String
    let avatar_link: String
    
    var id: String {
        room_id
    }
    
    enum CodingKeys: String, CodingKey {
        case room_id
        case room_name
        case dateCreated = "date_created"
        case last_message
        case date_message
        case user_id
        case avatar_link
    }
}
