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
    
    func loadUsers() async throws {
        print("essai")
    }
}

// ---------------------
struct UsersView: View {
    
    @StateObject var viewModel = UsersViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack {
            Color.theme.background
            List {
            }
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            // .onAppear {
            .task {
                do {
                    try await viewModel.loadUsers()
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

//#Preview {
//    UsersView()
//}
