//
//  ContactManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 29/01/2024.
//
// Utilisé par NewMessageView
// Contacts du téléphone

import Foundation
import Contacts

struct Contact: Identifiable, Hashable {
    let id = UUID().uuidString
    let nom: String
    let email: String

//    func hash(into hasher: inout Hasher) {
//        hasher.combine(email)
//    }
    
}

final class ContactManager {
    
    static let shared =  ContactManager()
    
    init() { }
    
    func mockContacts() async -> [Contact] {
        let myContact = [
            Contact(nom: "Dugenou", email: "mdugenoun@test.com"),
            Contact(nom: "Dugommier", email: "mdugommier@test.com"),
            Contact(nom: "Leroy", email: "mdLeroy@test.com"),
            Contact(nom: "Machin", email: "mdMachin@test.com"),
            Contact(nom: "Rutou", email: "mRutou@test.com"),
            Contact(nom: "Maerou", email: "mMaerou@test.com"),
            Contact(nom: "Furou", email: "mFurou@test.com"),
            Contact(nom: "Janin", email: "mJanin@test.com"),
            Contact(nom: "Jenor", email: "mJenor@test.com"),
            Contact(nom: "Gured", email: "mGured@test.com"),
            Contact(nom: "Noute", email: "mNoute@test.com"),
            Contact(nom: "Leroux", email: "mLeroux@test.com"),
        ]
        
        return myContact
    }
    
    func getAllContacts() async -> [Contact] {
        var contacts: [Contact] = []
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { uncontact, result in
                let nom = uncontact.givenName
                let email =  uncontact.emailAddresses.description
                let qqun = Contact(nom: nom, email: email)
                contacts.append(qqun)
            })
        } catch {
            print("getAllContacts - Error getting documents: \(error.localizedDescription)")
            return []
        }
        return contacts
    }
}
