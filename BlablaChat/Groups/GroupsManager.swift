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

    
    func loadContacts() -> [ContactModel]? {
        
        var contacts: [ContactModel] = []
        var sortedContacts: [ContactModel] = []
        
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
                    contacts.append(ContactModel(prenom: prenom, nom: nom, email: email))
                }
//                print(contact.givenName)
//                print(contact.familyName)
//                print(contact.emailAddresses.first?.value.description ?? "")
            })
            sortedContacts = contacts.sorted { $0.nom < $1.nom}
            return sortedContacts
         }
        catch let erreur {
            print(erreur)
            return nil
        }
    }

    
}
