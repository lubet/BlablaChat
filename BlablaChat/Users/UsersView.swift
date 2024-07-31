//
//  UsersView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 31/07/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

@MainActor
final class UsersViewModel: ObservableObject {
    
    private(set) var users: [DBUser] = []
    
    func loadUsers() async {
        self.users = try! await UserManager.shared.getAllUsers()
    }
    
    
}


struct UsersView: View {
    
    @StateObject var viewModel = UsersViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    let didSelectedNewUser: (String) -> ()
    
    var body: some View {
            List {
                ForEach(viewModel.users) { oneUser in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectedNewUser(oneUser.email!)
                    } label: {
                        UsersCellView(email: oneUser.email!)
                    }
                }
            }
            .task {
                await viewModel.loadUsers()
            }
    }
}

//#Preview {
//    UsersView()
//}
