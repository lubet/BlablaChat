//
//  UIApplication.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 09/01/2025.
//
// Fais disparaitre le clavier quand on appuie sur la croix de remise à blanc de la zone texte de la barre de recherche

import Foundation
import SwiftUI

extension UIApplication {
    
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
