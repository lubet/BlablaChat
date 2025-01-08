//
//  ContactBootcamp.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 06/01/2025.
//

//
//  ContentView.swift
//  ContactsBootcamp
//
//  Created by Lubet-Moncla Xavier on 06/01/2025.
//
// background and main threads

import SwiftUI

class ContactBootcampViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func fetchData() {
        DispatchQueue.global().async { // background thread
            let newData = self.downloadData()
            
            DispatchQueue.main.async { // main thread (always for the UI
                self.dataArray = newData
            }
        }
    }
    
    private func downloadData() -> [String] {
        var data: [String] = []
        for x in 0..<100 {
            data.append("\(x)")
            // print(data)
        }
        return data
    }
}

struct ContactBootcamp: View {
    
    @StateObject var vm = ContactBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("LOAD DATA")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .onTapGesture {
                        vm.fetchData()
                    }
                ForEach(vm.dataArray, id: \.self) { item in
                    Text(item)
                        .font(.headline)
                        .foregroundColor(.red)
                }
                        
            }
        }
    }
}

#Preview {
    ContactBootcamp()
}
