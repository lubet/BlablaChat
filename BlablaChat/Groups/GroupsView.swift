//
//  GroupsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/08/2025.
//

import SwiftUI

@MainActor
class GroupsViewModel: ObservableObject {
    
    @Published var contacts: [ContactModel] = []
    
    init () {
        loadContacts()
    }
    
    func loadContacts() {
        contacts = GroupsManager.shared.loadContacts()!
    }
    
}

struct GroupsView: View {
    
    @StateObject private var viewModel = GroupsViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    GroupsView()
}
