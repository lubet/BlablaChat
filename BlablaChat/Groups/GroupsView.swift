//
//  GroupsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/08/2025.
//

import SwiftUI
import Contacts

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []

    init() {
        loadData()
    }
    
    func loadData() {
                contacts.append(Contact(nom: "Leroy", prenom: "Marcel", email: "mleroy@test.com"))
                contacts.append(Contact(nom: "Gured", prenom: "Robert", email: "rgured@test.com"))
                contacts.append(Contact(nom: "Dujou", prenom: "Roger", email: "rdujou@test.com"))
                contacts.append(Contact(nom: "Lafon", prenom: "Albert", email: "alafon@test.com"))
    }

}

struct GroupsView: View {
    
    @StateObject var vm: GroupsViewModel = GroupsViewModel()
    
    var body: some View {
        ZStack {
            Color.theme.background
            List
            {
                ForEach(vm.contacts) { item in
                    Text(item.nom)
                }
            }
        }
    }
}

#Preview {
    GroupsView()
}
