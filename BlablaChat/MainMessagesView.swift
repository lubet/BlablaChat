//
//  MainMessagesView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 07/01/2024.
//

import SwiftUI

@MainActor
final class MainMessagesViewModel : ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authResult = try AuthManager.shared.getAuthenticatedUser()
        self.user = try await FirestoreManager.shared.getUser(userId: authResult.uid)
    }
}

// ---------------------------------------------------------------
struct MainMessagesView: View {
    
    @ObservedObject private var viewModel = MainMessagesViewModel()
    
    @State var LogOutSheet = false
    @State private var url: URL? = nil
    @State private var image: UIImage? = nil
    @State private var email: String = ""
    
    // Navbar ---------------------------
    private var customNavBar: some View {
        HStack(spacing: 16) {
            if let url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(email)")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            
            Spacer()
            Button {
                LogOutSheet.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .onAppear { // Nick a mis Task à la place de onAppear (.task)
            Task {
                try? await viewModel.loadCurrentUser()
                
                guard let user = viewModel.user else { return }
                
                if let path = user.imageLink {
                    self.url = URL(string: path)
                }
                
                if let email = user.email {
                    self.email = email
                }
            }
        }

        .padding()
        .actionSheet(isPresented: $LogOutSheet) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                }),
                    .cancel()
            ])
        }
    }
    
    // Corp -----------------------------------------
    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                messagesView
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
}

// Liste ----------------------------------------------------------
private var messagesView: some View {
    ScrollView {
        ForEach(0..<10, id: \.self) { num in
            VStack {
                HStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading) {
                        Text("Username")
                            .font(.system(size: 16, weight: .bold))
                        Text("Message sent to user")
                            .font(.system(size: 14))
                            .foregroundColor(Color(.lightGray))
                    }
                    Spacer()
                    
                    Text("22d")
                        .font(.system(size: 14, weight: .semibold))
                }
                Divider()
                    .padding(.vertical, 8)
            }.padding(.horizontal)
            
        }.padding(.bottom, 50)
    }
}

private var newMessageButton: some View {
    Button {
        
    } label: {
        HStack {
            Spacer()
            Text("+ New Message")
                .font(.system(size: 16, weight: .bold))
            Spacer()
        }
        .foregroundColor(.white)
        .padding(.vertical)
        .background(Color.blue)
        .cornerRadius(32)
        .padding(.horizontal)
        .padding(.vertical)
        .shadow(radius: 15)
    }
}
struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
