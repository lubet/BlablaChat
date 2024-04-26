//
//  Essai4View.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/04/2024.
//

import SwiftUI

struct Essai4View: View {
    
    let email: String
    
    var body: some View {
        Text("\(email)")
    }
}

struct Essai4View_Previews: PreviewProvider {
    static var previews: some View {
        Essai4View(email: "mon email")
    }
}
