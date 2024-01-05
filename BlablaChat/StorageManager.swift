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
    
    // Obtenir l'image - path = nom de l'image
    func getData(userId: String, path: String) async throws -> Data {
        try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    // Sauvegarde de l'image dans Storage
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
                
        let path = "\(UUID().uuidString).jpeg"
        let returnMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
                
        guard let path = returnMetaData.path, let name = returnMetaData.name else {
            throw URLError(.badServerResponse)
        }
         
        return(path, name)
    }
    
    // Transformation de l'image SWiftUI en data et appel de saveImage avec data et userId
    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            throw URLError(.badServerResponse)
        }
        // Appel de la fonction saveImage(data...) ci-dessus.
        return try await saveImage(data: data, userId: userId)
    }
    
}
