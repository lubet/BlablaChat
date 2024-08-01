//
//  MemberModel.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 01/08/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Member: Identifiable, Codable {
    let id: String
    let from_id: String
    let to_id: String
    let room_id: String
    let date_created: Timestamp
    
    init(
        id: String,
        from_id: String,
        to_id: String,
        room_id: String,
        date_created:Timestamp
    ) {
        self.id = id
        self.from_id = from_id
        self.to_id = to_id
        self.room_id = room_id
        self.date_created = Timestamp()
    }
}
