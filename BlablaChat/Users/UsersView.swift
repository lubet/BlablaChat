//
//  UsersView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 31/07/2024.
//
// Affichage des users avec possibilté de recherche


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class UsersViewModel: ObservableObject {
    
    @Published private(set) var allUsers: [DBUser] = []
    
    func loadUsers() async throws {
        allUsers = try await UsersManager.shared.getAllUsers()
       // print("\(allUsers)")
    }
}


// ---------------------
struct UsersView: View {
    
    @StateObject var viewModel = UsersViewModel()
    
    @State private var searchTerm = ""
    
    @Environment(\.presentationMode) var presentationMode

    var filteredUsers: [DBUser] {
        guard !searchTerm.isEmpty else { return viewModel.allUsers}
        return viewModel.allUsers.filter { $0.email!.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    let didSelectedNewUser: (String) -> () // call back
    
    var body: some View {
        
        ZStack {
            Color.theme.background
            NavigationStack {
                List {
                    ForEach(filteredUsers) { oneUser in
                        Button {
                            presentationMode.wrappedValue.dismiss() // Fermeture de la vue
                            didSelectedNewUser(oneUser.email!)      // Ouverture de la vue précédente "NewMessagesView" avec passage de l'email selectionné
                        } label: {
                            UsersCellView(oneUser: oneUser)
                        }
                    }
                }
                .searchable(text: $searchTerm, placement: .automatic, prompt: "Recherche d'un contact")
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                // .onAppear {
                .task {
                    do {
                        try await viewModel.loadUsers() // Chargement des users de la base "Users"
                    } catch {
                        print("UsersView-loadUsers Aucun users:")
                    }
                }
                //}
                .listStyle(PlainListStyle())
                .navigationTitle("Users")
                .padding(.top,10)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            ContactsView()
                        } label: {
                            Image(systemName: "person.fill.badge.plus")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    UsersView()
//}
