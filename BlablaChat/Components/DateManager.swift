//
//  DateManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 10/06/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

func dateManager(dateMessage: Timestamp) -> String {
    
    let _ = dateMessage.dateValue() // Timestamp -> date 
    
    let first = Date.now
    
    let isToday = Calendar.current.isDateInToday(first)
    
    if (isToday) {
        return (Date().formatted(date: .numeric, time:.shortened))
    } else {
        return "date"
    }
}
