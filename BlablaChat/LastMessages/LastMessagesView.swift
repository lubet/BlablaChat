//
//  LastView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 23/03/2024.
//
// Liste de derniers messages par room


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

@MainActor
class LastMessagesViewModel: ObservableObject {
    
    func logOut() {
        try? UsersManager.shared.signOut()
    }
    
}

// -----------------------------------------------------------------------------

struct LastMessagesView: View {
    
    @ObservedObject var viewModel: LastMessagesViewModel = LastMessagesViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            VStack {
                NavigationLink {
                    // -> UsersView -> Contacs -> Messages
                    // -> UsersView -> Messages
                } label: {
                    HStack {
                        Text("Nouveau message")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    //.shadow(radius: 15)
                }
                .padding(.bottom,10)
                Button("Logout") {
                    viewModel.logOut()
                    showSignInView = true
                }
            }
        }
    }
}

struct LastMessages_Previews: PreviewProvider {
    static var previews: some View {
            LastMessagesView(showSignInView: .constant(false))
    }
}
