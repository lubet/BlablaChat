//
//  AuthenticationView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 15/04/2024.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack {
            
            NavigationLink {
                LoginEmailView()
            } label: {
                Text("S'authentifié avec l'email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Authentification")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView()
        }
    }
}
