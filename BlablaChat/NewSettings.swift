//
//  NewSettings.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/10/2024.
//

import SwiftUI
import PhotosUI

@MainActor
final class NewSettingsModel: ObservableObject {
    
    @Published var monImage: UIImage = UIImage(resource: .autre)
    
    func addImage() async {
        // self.monImage = UIImage(resource: .autre)
        
        guard let authUser = try? AuthManager.shared.getAuthenticatedUser() else { return }
        let user_id = authUser.uid
        
        guard let httpAvatar = try? await UsersManager.shared.getAvatar(contact_id: user_id) else {
            print("httpAvatar = nil")
            return
        }
        
        guard let imageAvatar = try? await StorageManager.shared.getImage(userId: user_id, path: httpAvatar) else {
            self.monImage = UIImage(resource: .mon)
            print("imageAvatar = nil")
            return
        }
        
        print("imageAvatar: \(imageAvatar)")
        self.monImage = imageAvatar
    }

    func logOut() throws {
        try AuthManager.shared.signOut()
    }

    
}


struct NewSettings: View {
    @Binding var showSignInView: Bool
    
    @StateObject private var viewModel = NewSettingsModel()
    
    @State private var avatarImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    var body: some View {
        ZStack() {
            VStack(spacing: 40) {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.logOut()
                            showSignInView = true
                            return
                        } catch {
                            print(error)
                        }
                    }
                }
                
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    Image(uiImage: avatarImage ?? viewModel.monImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(.circle)
                }
                .onChange(of: photosPickerItem) { _, _ in
                    Task {
                        if let photosPickerItem,
                           let data = try await photosPickerItem.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                avatarImage = image
                            }
                        }
                        photosPickerItem = nil
                    }
                }
                .onAppear {
                    Task {
                        try await viewModel.addImage()
                    }
                }
                
                
                
            } // VStack
        } // ZStack
    }
    
    struct NewSettings_Previews: PreviewProvider {
        static var previews: some View {
            NewSettings(showSignInView: .constant(false))
        }
    }
}
