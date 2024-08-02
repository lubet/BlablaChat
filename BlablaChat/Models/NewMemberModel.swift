//
//  NewMemberModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 02/08/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NewMemberModel: Identifiable, Codable {
    let id: String
    let user_id: String
    let room_id: String
    
    init(
        id: String,
        user_id: String,
        room_id: String
    ) {
        self.id = id
        self.user_id = user_id
        self.room_id = room_id
    }
}
