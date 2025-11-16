//
//  RouterPath.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 16/11/2025.
//

import SwiftUI

class RouterPath: ObservableObject {
    @Published var path = NavigationPath()
    
    func reset() {
        path = NavigationPath()
    }
}
