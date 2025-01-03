//
//  Salons_Users.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/12/2024.
//
// un salon peut reunir plusieurs utilisateurs
// et un utilsateur peut faire partie de plusieurs salon
 
import Foundation

struct Salons_Users {
    let salon_id: String // -> Salon
    let userId: String // -> DBUser
    
    init(
        salon_id: String,
        userId: String
    ) {
        self.salon_id = salon_id
        self.userId = userId
    }

}
