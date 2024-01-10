//
//  NewMessageView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 10/01/2024.
//

import SwiftUI

@MainActor
final class NewMessageViewModel: ObservableObject {
    
    @Published var users: [DBUser] = []
    
    init() {
        Task {
            print("2")
            try await getUsers()
        }
    }
    
    func getUsers() async throws {
        print("3")
        self.users = try await FirestoreManager.shared.getAllUsers()
        print("ICI")
    }
}


struct NewMessageView: View {
    
    @StateObject private var viewModel = NewMessageViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.users) { user in
                    // Text(user.email ?? "")
                    Text("Zut")
                }
            }
            .navigationTitle("New Message")
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
//        .onAppear {
//           Task {
//                try await viewModel.getAllUsers()
//            }
//        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView()
    }
}
