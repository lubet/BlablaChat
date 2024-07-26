//
//  MessageShort.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 20/06/2024.
//

import Foundation

func MessageShort(message: String) -> String {
    
    var msg = message
    
    while (msg.count > 20) {
        if msg.lastIndex(of: " ") == nil {
                // extraire les 20 premiers caractères
            msg = String(msg.prefix(20)) + "..."
                print("Les 20 premiers")
                break
        }
        let index = msg.lastIndex(of: " ") ?? msg.endIndex
        msg = String(msg[..<index]) // Hello
    }
    
    return msg
}
