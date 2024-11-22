//
//  Face_Rater_AppApp.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 10/5/24.
//

import UIKit
import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {
    
    enum FRPushNotificationTopics: String {
        case ModelUpdate = "model_update"
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        // Subscribe to PN Topics
        Messaging.messaging().subscribe(toTopic: FRPushNotificationTopics.ModelUpdate.rawValue) { error in
            if let error = error {
                print("Failed to subscribe to topic: \(error.localizedDescription)")
            } else {
                print("Subscribed to model_updates topic")
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
            let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

        // ...

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        return [[.banner, .list, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        /* -- Unwrap Notification to trigger Model update
         if let type = userInfo["type"] as? String, type == FRPushNotificationTopics.ModelUpdate.rawValue {
                     // Trigger model download
                     Task {
                         try await downloadLatestModel() // Call your existing model download function
                     }
                 }
         */

        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)
          
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.noData)
    }
}

@main
struct Face_Rater_AppApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
