//
//  SearchBarView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 25/01/2024.
//
// A utliser pour saisir un message

import SwiftUI

struct SearchBarView: View {
    
    @State var searchText: String = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(searchText.isEmpty ?
                                 Color.black: Color.white
                )
            TextField("Recherche par le nom", text: $searchText)
                .foregroundColor(Color.black)
                .overlay (
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x:10)
                        .foregroundColor(Color.black)
                        .onTapGesture {
                            searchText = ""
                        }
                    ,alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.init("GrisClair")))
                .shadow(radius: 2)
        )
        .padding()
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
