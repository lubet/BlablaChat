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
    
    func persistImageToStorage(image:  UIImage, userId: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("persisterImageToStorage: pas d'image")
            return
        }
        userReference(userId: userId).putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("persistImageToStorage error: \(err)")
            }
        }
    }
    
}
