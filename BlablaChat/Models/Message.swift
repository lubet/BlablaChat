//
//  MessageModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 24/12/2024.
//

import Foundation

struct Message: Identifiable {
    let message_id: String
    let date_message: Date
    let message: String
    let from_user_id: String
    let to_user_id: String
    
    var id: String {
        message_id
    }

}
