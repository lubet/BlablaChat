//
//  GroupsManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/08/2025.
//

import Foundation
import Contacts

final class GroupsManager {
    
    static let shared = GroupsManager()
    
    init() { }
    
    func fetchContacts() -> [Contact] {
        
        var contacts: [Contact] = []
        
        contacts.append(Contact(nom: "Leroy", prenom: "Marcel", email: "mleroy@test.com"))
        contacts.append(Contact(nom: "Gured", prenom: "Robert", email: "rgured@test.com"))
        contacts.append(Contact(nom: "Dujou", prenom: "Roger", email: "rdujou@test.com"))
        contacts.append(Contact(nom: "Lafon", prenom: "Albert", email: "alafon@test.com"))
        
        return contacts
    }
    
}
