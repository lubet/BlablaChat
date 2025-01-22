//
//  Membres.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 22/01/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Membres: Identifiable, Codable {
    let id: String
    let salonId: String
    let userId: String // user ou contact

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case salonId = "salon_id"
        case userId = "user_id"
    }
}
