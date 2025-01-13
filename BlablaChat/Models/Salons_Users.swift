//
//  Salons_Users.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/12/2024.
//
// un salon peut reunir plusieurs utilisateurs
// et un utilsateur peut faire partie de plusieurs salon
 
import Foundation

struct Salons_Users: Codable {
    let salonId: String // -> Salons
    let userId: String // -> Users
    
    init(
        salonId: String,
        userId: String
    ) {
        self.salonId = salonId
        self.userId = userId
    }

}
