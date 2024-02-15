//
//  NewContactView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/02/2024.
//

import SwiftUI

@MainActor
final class NewContactViewModel: ObservableObject {
    
}


struct NewContactView: View {
    
    @StateObject private var newModel = NewContactViewModel()
    
    var body: some View {
        Text("Nouveau contact")
    }
}

struct NewContactView_Previews: PreviewProvider {
    static var previews: some View {
        NewContactView()
    }
}
