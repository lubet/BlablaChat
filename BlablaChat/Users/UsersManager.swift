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
    private func userDocument(userId: String) -> DocumentReference {
        return userCollection.document(userId)
    }
    
    // users
    private func usersCollection() -> CollectionReference {
        return userCollection
    }
    
    func createDbUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
//    func updateAvatar(userId: String, mimage: UIImage) async throws {
//        let (path, _) = try await StorageManager.shared.saveImage(image: mimage, userId: userId)
//        let lurl: URL = try await StorageManager.shared.getUrlForImage(path: path)
//        try await UsersManager.shared.updateImagePath(userId: userId, path: lurl.absoluteString) // maj Firestore
//        // print("updateAvatar \(lurl)")
//    }

}
