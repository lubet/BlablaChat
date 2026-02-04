//
//  GroupesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 04/02/2026.
//  Groupes de contacts

import SwiftUI

@MainActor
class GroupesViewModel: ObservableObject {
    
    @Published var contacts: [Contact] = []
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        
    }
    
}


struct GroupesView: View {
    
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    GroupesView()
}
