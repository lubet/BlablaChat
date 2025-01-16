//
//  Salons_Users.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/12/2024.
//
// un salon peut reunir plusieurs utilisateurs
// et un utilsateur peut faire partie de plusieurs salon
 
import Foundation

struct Salons_Users: Identifiable, Codable {
    let id: String
    let salonId: String // -> Salons
    let userId: String // -> Users
    
    enum CodingKeys: String, CodingKey {
        case id
        case salonId = "salon_id"
        case userId = "user_id"
    }
    
    init(
        id: String,
        salonId: String,
        userId: String
    ) {
        self.id = id
        self.salonId = salonId
        self.userId = userId
    }

}
