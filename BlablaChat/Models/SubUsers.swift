//
//  SubUsers.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/12/2025.
//
// Sous-collections users de salon (pour la relation n à n avec Users).
//

import Foundation

struct SubUsers: Identifiable, Codable, Hashable {
    let id: String
    let salonId: String
    let userId: String

    init(id: String = UUID().uuidString, salonId: String = "", userId: String = "") {
        self.id = id
        self.salonId = salonId
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case salonId = "salon_id"
        case userId = "user_id"
    }

}
