//
//  ContactManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/01/2024.
//
// Utilisé par NewMessageView

import Foundation
import Contacts

struct Contact: Identifiable {
    let id: String
    let nom: String
    let email: String
    
    init (
        id: String,
        nom:String,
        email:String
    ) {
        self.id = id
        self.nom = nom
        self.email = email
    }
    
}

final class ContactManager {
    
    static let shared =  ContactManager()
    
    init() { }
    
    
    func getAllContacts() async -> [Contact] {
        
        print("Ici")
        
        var contacts: [Contact] = []
        
        let store = CNContactStore()
        
        let keys = [CNContactGivenNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { uncontact, result in
                let nom = uncontact.givenName
                let email =  uncontact.emailAddresses.description
                let qqun = Contact(id: UUID().uuidString, nom: nom, email: email)
                contacts.append(qqun)
                print("\(nom)")
            })
        } catch {
            print(error)
        }
        
        return contacts
    }
}
