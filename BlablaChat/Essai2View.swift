//
//  Essai2View.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 14/01/2024.
//

import SwiftUI

class Essai2ViewModel: ObservableObject {
    
    func essai(userId: String) {
        print("func \(userId)")
    }
    
}

struct Essai2View: View {
    
    @StateObject private var vm = Essai2ViewModel()
    
    let userId: String
    
    var body: some View {
        List{
            Text("Text: (\(userId)")
        }
        .onAppear(){
            vm.essai(userId: userId)
        }
    }
}

struct Essai2View_Previews: PreviewProvider {
    static var previews: some View {
        Essai2View(userId: "12399")
    }
}
