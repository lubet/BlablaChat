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

    // Users dans "Storage" pour l'avatar du user
    private func userReference(userId: String) -> StorageReference {
        return storage.child("users").child(userId)
    }

    // Salons dans "Storage" pour la photo d'un message
    private func userReference(salonId: String) -> StorageReference {
        return storage.child("salons").child(salonId)
    }

    // functions ------------------------------------
    
    // URL
    func getUrlForImage(path: String) async throws -> URL {
        return try await Storage.storage().reference(withPath: path).downloadURL()
    }
    
    // NON Utiliser - Retourne une dataImage, path = chemin complet /users/userId/data.jpeg
    func getData(userId: String, path: String) async throws -> Data {
        // try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
        return try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }

    // NON utiliser - Retourne une UIImage à partir d'une dataImage de Storage
    func getImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        return image
    }
    
    // Sauvegarde de l'avatar du user dans Storage
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
                
        let name = "\(UUID().uuidString).jpeg"
        let returnMetaData = try await userReference(userId: userId).child(name).putDataAsync(data, metadata: meta)
                
        guard let path = returnMetaData.path, let name = returnMetaData.name else {
            throw URLError(.badServerResponse)
        }
        return(path, name)
    }
    
    // Transformation de l'image SWiftUI en data et appel de saveImage du user avec data et userId
    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            throw URLError(.badServerResponse)
        }
        // Appel de la fonction saveImage(data...) ci-dessus.
        return try await saveImage(data: data, userId: userId)
    }
    
    // Supprimer l'avatar dans "Storage"
    func deleteAvatar(httpAvatar: String) async throws {
       //  print("httpAvatar: \(httpAvatar)")
        let refAvatar = storage.storage.reference(forURL: httpAvatar)
        do {
            try await refAvatar.delete()
        } catch {
          print("deleteAvatar: error")
        }
    }
    
    // Sauvegarde de l'image du message dans "Storage"
    func saveImage(data: Data, salonId: String) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
                
        let name = "\(UUID().uuidString).jpeg"
        let returnMetaData = try await userReference(salonId: salonId).child(name).putDataAsync(data, metadata: meta)
                
        guard let path = returnMetaData.path, let name = returnMetaData.name else {
            throw URLError(.badServerResponse)
        }
        return(path, name)
    }
    
    // Transformation de l'image SWiftUI en data et appel de saveImage image du message avec data et userId
    func saveImage(image: UIImage, salonId: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            throw URLError(.badServerResponse)
        }
        // Appel de la fonction saveImage(data...) ci-dessus.
        return try await saveImage(data: data, salonId: salonId)
    }

}
