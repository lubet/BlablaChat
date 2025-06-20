//
//  Color.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 26/07/2024.
//

import Foundation
import SwiftUI

extension Color {
    
    static let theme = ColorTheme()
    
}

struct ColorTheme {
    let backtext = Color("BackTextIinputColor") // TextField
    let forground = Color("ForgroundTextColor") // TextField
    let background = Color("BackgroundColor")   // Fond
    let circlecolor = Color("CircleColor") // Cercle autour d'une image
}
