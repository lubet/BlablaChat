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
    
    @Published private(set) var users: [DBUser] = []
    
    func loadUsers() async {
        self.users = try! await UserManager.shared.getAllUsers()
    }
}

// ---------------------
struct UsersView: View {
    
    @StateObject var viewModel = UsersViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    let didSelectedNewUser: (String) -> () // call back
    
    @State private var searchTerm: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
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
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Utilisateurs")
            .padding(.top,10)
        }
    }
}

//#Preview {
//    UsersView()
//}
