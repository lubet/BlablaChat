//
//  LoginManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 05/11/2025.
//

import Foundation
import Contacts

final class LogInManager {
    
    static let shared = LogInManager()
    
    // Renvoie le nom et le prenom du contact trouvés dans les contacts à partir de l'email
    func getContactName(email: String) -> (nom: String, prenom: String) {
        
        var nom: String = ""
        var prenom: String = ""
        
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
        
        let store = CNContactStore()
        do {
            let predicate = CNContact.predicateForContacts(matchingEmailAddress: email)
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            nom = contacts.first?.givenName ?? email
            prenom = contacts.first?.familyName ?? ""
        } catch {
            print("Failed to fetch contact, error: \(error)")
        }
        return (nom, prenom)
    }
}

