//
//  NavStackView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 31/01/2024.
//

import SwiftUI

struct NavStackView: View {
    
    let fruits: [String] = ["Orange","Pomme","Poire"]
    
    var body: some View {
        NavigationStack {
            Spacer()
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(fruits, id: \.self ) { fruit in
                        
                        NavigationLink(value: fruit) {
                            Text("\(fruit)")
                        }
                    }
                }
            }
            .navigationTitle("Des fruits")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationDestination(for: String.self) { value in
                secondView(value: value)
            }
        }
    }
}

struct secondView: View {
    
    let value: String
    
    var body: some View {
        Text("Ma seconde view pour \(value)")
    }
}

struct NavStackView_Previews: PreviewProvider {
    static var previews: some View {
        NavStackView()
    }
}
