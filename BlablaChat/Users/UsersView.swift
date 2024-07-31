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
    @Published private(set) var usersfiltered : [DBUser] = []
    
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
        
    var filteredUsers: [DBUser] {
        guard !searchTerm.isEmpty else { return viewModel.users }
        return viewModel.users.filter {$0.email!.localizedCaseInsensitiveContains(searchTerm)}
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                VStack {
                    List {
                        ForEach(filteredUsers) { oneUser in
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                didSelectedNewUser(oneUser.email!)
                            } label: {
                                UsersCellView(oneUser: oneUser)
                            }
                        }
                    }
                    .searchable(text: $searchTerm, prompt: "Recherche")
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .task {
                        await viewModel.loadUsers()
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Participants")
            .padding(.top,10)
        }
    }
}

//#Preview {
//    UsersView()
//}
