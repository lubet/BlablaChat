//
//  MessageBubble.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 12/08/2024.
//

import Foundation

struct MessageBubble: Identifiable{
    let id: String
    let message_text: String
    let message_date: String
    let received: Bool
    let imageLink: String
    let to_id: String
    
    init(id: String, message_text: String, message_date: String, received: Bool, imageLink: String, to_id: String) {
        self.id = id
        self.message_text = message_text
        self.message_date = message_date
        self.received = received
        self.imageLink = imageLink
        self.to_id = to_id
    }
}
