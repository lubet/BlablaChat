//
//  ContactsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 07/12/2024.
//

import SwiftUI

@MainActor
class ContactsViewModel: ObservableObject {
    
    @Published var contacts: [ContactsViewModel] = []
    
    init() {
        loadContacts()
    }
    
    func loadContacts() {
        
    }
    
}

struct ContactsView: View {
    
    @StateObject var viewModel: ContactsViewModel = ContactsViewModel()
    
    var body: some View {
        List {
            Text("Hi !")
        }
        .navigationTitle("Contacts")
    }
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactsView()
        }
    }
}

