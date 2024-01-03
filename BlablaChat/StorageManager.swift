//
//  StorageManager.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import Foundation
import FirebaseStorage
import UIKit


final class StorageManager {
    
    static let shared = StorageManager()
    init() { }
    
    // Réferences ------------------------------------

    private let storage = Storage.storage().reference()
    
    private var imageReference : StorageReference {
        return storage.child("images")
    }

    private func userReference(userId: String) -> StorageReference {
        return storage.child("users").child(userId)
    }

    // functions ------------------------------------
    
    func persistImageToStorage(userId: String, image:  UIImage) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("persisterImageToStorage: pas d'image")
            return
        }
        // Création de l'image dans storage
        userReference(userId: userId).putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("persistImageToStorage error save in Storage: \(err)")
            } else {
                // Url de l'image
                self.userReference(userId: userId).downloadURL { url, err in
                    if let err = err {
                        print("persistImageToStorage error to get an url: \(err)")
                    } else {
                        print("persistImageToStorage url: \(url?.absoluteString ?? "nil")")
                        
                        guard let url = url  else { return }
                        
                        // Création du profil Firestore avec l'image si il y en a une
                        self.storeUserInformation(imageProfileUrl: url)
                    }
                }

            }
        }
    }
    
    func storeUserInformation(imageProfileUrl: URL) -> URL{
        return imageProfileUrl
    }
    
}
