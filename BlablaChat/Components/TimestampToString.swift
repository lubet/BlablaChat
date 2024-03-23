//
//  TimestampToString.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

func timeStampToString(dateMessage: Timestamp) -> String {
    let date = dateMessage.dateValue()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .medium
    dateFormatter.locale = Locale(identifier: "FR-fr")
    let strDate = "\(dateFormatter.string(from: date))"
    return strDate
}
