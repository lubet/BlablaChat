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
            HandleSendView(to_user: DBUser(userId: "123456", email: "toto@test.com", dateCreated: Date(), imageLink: "https://"),
                           from_user: DBUser(userId: "789012", email: "toto@test.com", dateCreated: Date(), imageLink: "https://"))
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
