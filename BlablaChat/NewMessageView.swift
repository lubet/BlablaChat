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

    func getUsers() async throws {
        self.users = try await FirestoreManager.shared.getAllUsers()
    }
}


struct NewMessageView: View {
    
    @StateObject private var viewModel = NewMessageViewModel()
        
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.users) { user in
                    HStack(spacing: 20) {
                        if let url = user.imageLink {
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            }
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 70))
                                .padding()
                                .foregroundColor(Color(.label))
                        }
                        Text(user.email ?? "")
                        Spacer()
                    } .padding(.horizontal)
                    Divider()
                }
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
