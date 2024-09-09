//
//  BlablaChatApp.swift
//  BlablaChat
//
//  Created by Lubet-Moncla Xavier on 03/01/2024.
//
/*
Name:My Apple Key
Key ID:6T9B4Y3RT9
Services:Apple Push Notifications service (APNs)
AuthKey_6T9B4Y3RT9.p8 dans telechargement et dans Document/Apple Key
Team ID: Z2D42B65AU
*/

import SwiftUI
import Firebase
import UserNotifications

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
