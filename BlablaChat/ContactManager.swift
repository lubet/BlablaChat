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
    let nom: String?
    let prenom: String?
    let email: String?
    
    init (
        id: String,
        nom:String,
        prenom:String,
        email:String
    ) {
        self.id = UUID().uuidString
        self.nom = nom
        self.prenom = prenom
        self.email = email
    }
    
}

final class ContactManager {
    
    static let shared =  ContactManager()
    
    init() { }
    
    
    func fetchAllContacts() {
        
        var contacts: [Contact] = []
        
        let store = CNContactStore()
        
        let keys = [CNContactGivenNameKey, CNContactMiddleNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { contact, result in
                print(contact.givenName)
            })
        } catch {
            print(error)
        }
    }
}
