//
//  ContactEssaiView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 30/01/2024.
//

import SwiftUI
import Contacts

struct ContactEssaiView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .padding()
            .onAppear {
                Task.init {
                    await fetchContacts()
                }
            }
    }
    
    //    func getAllContacts() async throws -> [Contact] {
    //            [
    //                Contact(id: "1", nom: "Dudu", prenom: "Maurice", email: "maurice@test.com"),
    //                Contact(id: "2", nom: "Dudu", prenom: "Robert", email: "maurice@test.com"),
    //                Contact(id: "3", nom: "Didi", prenom: "Emile", email: "maurice@test.com"),
    //                Contact(id: "4", nom: "Toto", prenom: "Gaston", email: "maurice@test.com"),
    //                Contact(id: "5", nom: "Tete", prenom: "Gaston", email: "maurice@test.com"),
    //            ]
    //        }

    
    func fetchContacts() async {
        
        let store = CNContactStore()
        
        let keys = [CNContactGivenNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { contact, result in
                print(contact.givenName)
            })
        } catch {
            print("Erreur")
        }
    }
}

struct ContactEssaiView_Previews: PreviewProvider {
    static var previews: some View {
        ContactEssaiView()
    }
}
