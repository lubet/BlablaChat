import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

private let dbFS = Firestore.firestore()

final class UsersManager {
    
    static let shared = UsersManager()
    init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    // user
    private func userDocument(id: String) -> DocumentReference {
        return userCollection.document(id)
    }
    
    // users
    private func usersCollection() -> CollectionReference {
        return userCollection
    }
    
    func createDbUser(user: DBUser) async throws {
        try userDocument(id: user.id).setData(from: user, merge: false)
    }
    
    func updateAvatar(userId: String, image: UIImage) async throws -> String {
        let (path, _) = try await StorageManager.shared.saveImage(image: image, userId: userId)
        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
        try await UsersManager.shared.updateImagePath(userId: userId, path: lurl.absoluteString)
        return lurl.absoluteString
    }
    
    func getAvatar(contact_id: String) async throws -> String {
        do {
            let querySnapshot = try await userCollection
                .whereField("user_id", isEqualTo: contact_id)
                .getDocuments()
            
            for document in querySnapshot.documents {
                let user = try document.data(as: DBUser.self)
                if (user.userId == contact_id) {
                    return user.avatarLink ?? ""
                }
            }
        } catch {
            print("getAvatar - Error getting documents: \(error)")
        }
        print("getAvatar: non trouvé pour contact-id: \(contact_id)")
        
        return ""
    }

    func updateImagePath(userId: String, path: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.avatarLink.rawValue : path,
        ]
        try await userDocument(id: userId).updateData(data)
    }

}
