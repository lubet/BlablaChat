//
//  MessageModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/08/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    let id: String
    let from_id: String
    let message_text:String
    let date_send: Timestamp
    let room_id: String
    let image_link: String?
    let to_id: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case from_id
        case message_text
        case date_send
        case room_id
        case image_link
        case to_id
    }
    
    init(
        id: String,
        from_id: String,
        message_text: String,
        date_send: Timestamp,
        room_id: String,
        image_link: String?,
        to_id: String
    ) {
        self.id = id
        self.from_id = from_id
        self.message_text = message_text
        self.date_send = date_send
        self .room_id = room_id
        self.image_link = image_link
        self.to_id = to_id
    }
}
