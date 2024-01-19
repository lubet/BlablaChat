//
//  NewMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 10/01/2024.
//
// Choisir un user dans la liste pour céer un nouveau message qui lui est destiné

import SwiftUI

@MainActor
final class NewMessageViewModel: ObservableObject {
    
    @Published var users: [DBUser] = []

    func getUsers() async throws {
        self.users = try await UserManager.shared.getAllUsers()
    }
}

struct NewMessageView: View {
    
    @StateObject private var viewModel = NewMessageViewModel()
        
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(viewModel.users) { user in
                        NavigationLink(value: user.userId) {
                            NewMessageCellView(user: user)
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                ChatLogView(selectedUserId: value) // TO->
            }
            .navigationTitle("New Message")
            .padding(.vertical)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
        .onAppear {
           Task {
               try await viewModel.getUsers()
            }
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView()
    }
}
