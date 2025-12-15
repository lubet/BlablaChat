//
//  EmailShort.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 20/06/2024.
//

import Foundation


func EmailShort(email: String) -> String {
    let index = email.firstIndex(of: "@") ?? email.endIndex
    let debut = email[..<index]

    return String(debut)
}
