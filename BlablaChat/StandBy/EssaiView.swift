//
//  EssaiView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2025.
//

import SwiftUI
import Contacts

struct EssaiView: View {
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        .onAppear {
            Task.init {
                await fetchAllContacts()
            }
        }
    }
    
    func fetchAllContacts() async {
        // Accesse to contact store
        let store = CNContactStore()
        
        // Which data i want to fetch
        let keys = [CNContactGivenNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        // fetch request
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        // Call method to fetch the contact
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { contact,
                result in
                // print(contact.givenName)
                
//                for email in contact.emailAddresses {
//                    switch email.label {
//                    case CNLabelEmailiCloud:
//                        // print("\(email.value)")
//                    case .none:
//                        //print("none")
//                    case .some(_):
//                        //print("some")
//                    }
//                }
            })
        }
        catch {
            print("********* erreur")
        }
    }
    
}

#Preview {
    EssaiView()
}
