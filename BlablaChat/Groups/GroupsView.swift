//
//  GroupsView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/08/2025.
//  View permettant de selectionner un contact ou plusieurs si
//  on veut créer un groupe

import SwiftUI
import Contacts

@MainActor
class GroupsViewModel: ObservableObject {
    
    @AppStorage("currentUserId") var currentUserId: String?
    
    @Published var sortedContacts: [Contact] = []
    @Published var checkedContacts: [Contact] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        var contacts: [Contact] = []
        contacts.append(Contact(nom: "Leroy", prenom: "Marcel", email: "mleroy@test.com"))
        contacts.append(Contact(nom: "Gured", prenom: "Robert", email: "rgured@test.com"))
        contacts.append(Contact(nom: "Dujou", prenom: "Roger", email: "rdujou@test.com"))
        contacts.append(Contact(nom: "Lafon", prenom: "Albert", email: "alafon@test.com"))
        sortedContacts = contacts.sorted { $0.nom < $1.nom}
    }
    
    func fetchAllContacts() {
        var contacts: [Contact] = []
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock:
                                            {(contact, stop) in
                let email = contact.emailAddresses.first?.value.description ?? ""
                let prenom = contact.givenName
                let nom = contact.familyName
                if ((prenom != "" || nom != "") && email != "") {
                    contacts.append(Contact(nom: nom, prenom: prenom, email: email))
                }
            })
            sortedContacts = contacts.sorted { $0.nom < $1.nom}
        }
        catch let erreur {
            print(erreur)
        }
    }
    
    // Affiche une coche dans le carré quand on click dessus et maj l'objet.
    func checkContact(contact: Contact) {
        if let index = sortedContacts.firstIndex(where: { $0.id == contact.id}) { sortedContacts[index] = contact.updateCompletion() // méthode model
        }
    }
    
    // Charger les checkedContacts
    func loadCheckedContacts() {
        checkedContacts = sortedContacts.filter { user in user.isChecked }
    }
        
    // Gestion des contacts checkés
    func checkedContacts() async throws {
        for checkedContact in checkedContacts {
            var userId: String = ""
            let dbuser = try await UsersManager.shared.searchUser(email: checkedContact.email)
            if dbuser == nil {
                let user = DBUser(email: checkedContact.email)
                try await UsersManager.shared.createDbUser(user: user) // sans l'image
                let image = UIImage.init(systemName: "person.circle.fill")!
                try await UsersManager.shared.updateAvatar(userId: user.userId, mimage: image) // Storage + maj de
                userId = user.userId
            } else {
                userId = dbuser!.userId
            }
 
            // 1) Si l'un des chkContacts n'existe pas dans membre -> créer un salon
            // et créer autant de membres avec le même salonId et sortir du for
            // Existe t'il dans membres
            let ok = try await MembresManager.shared.searchMembre(userId: userId)
        }
    }
}

struct GroupsView: View {
    
    @StateObject var vm: GroupsViewModel = GroupsViewModel()
    
    @State private var searchText: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    // filteredContacts mis ici dans la structure cela a permis que onTapGesture fonctionne;
    // sous la forme @Published dans le ViewModel cela ne fonctionnait pas. Bug iOS 18 ?
    var filteredContacts: [Contact] {
        guard !searchText.isEmpty else { return vm.sortedContacts }
        return vm.sortedContacts.filter { $0.nom.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                List {
                    ForEach(filteredContacts) { item in
                        GroupRowView(contact: item)
                            .onTapGesture {
                                withAnimation(.linear) {
                                    vm.checkContact(contact: item)
                                }
                            }
                    }
                }
            }
            .navigationTitle("Contacts")
            .searchable(text: $searchText, prompt: "Quel contact ?")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "xmark")
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            try await vm.checkedContacts()
                            vm.loadCheckedContacts()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text("OK")
                            .font(.headline)
                    })
                }
            }
            
            
        }
    }
}

#Preview {
    GroupsView()
}
