//
//  BlablaChatApp.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//

import SwiftUI
import Firebase

@main
struct BlablaChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
             RootView()
                // LastMessagesView
                //AuthenticationView()
            

            // NewContactView()
            // LoginEmailView()
            // RoomMessagesView(room_id)
            // MessagesView() obsoléte
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
