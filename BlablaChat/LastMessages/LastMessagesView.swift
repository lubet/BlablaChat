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
    
}

// -----------------------------------------------------------------------------

struct LastMessagesView: View {
    
    @ObservedObject var viewModel: LastMessagesViewModel = LastMessagesViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                NavigationLink {
                    // -> UsersView -> Contacs -> Messages
                    // -> UsersView -> Messages
                } label: {
                    HStack {
                        Spacer()
                        Text("Nouveau message")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(32)
                    .padding(.horizontal)
                    //.shadow(radius: 15)
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
