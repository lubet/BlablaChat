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
    
    // get all my users
    
    
    
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

                NavigationLink("Nouveau message") {
                    UsersView()
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
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
        NavigationStack {
            LastMessagesView(showSignInView: .constant(false))
        }
    }
}
