//
//  TestView.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 17/12/2025.
//

import SwiftUI
import SwiftfulRouting

struct TestView: View {
    @Environment(\.router) var router
    
    let oneContact: ContactModel
    
    var body: some View {
        VStack {
            Text("TestView").font(.largeTitle).padding()
            Spacer()
            Button("->ContentView->LastMessagesView", action:  {
                router.dismissScreenStack()
            })
        }
    }
}

//#Preview {
//    TestView()
//}
