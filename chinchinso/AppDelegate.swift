//
//  AppDelegate.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 10. 20..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var rootNavigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // FIREBASE Config
        FirebaseApp.configure()
        // Push Notification Config
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization( options: [.alert, .badge, .sound], completionHandler: {_, _ in })
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        }
        UIApplication.shared.registerForRemoteNotifications()    // Notfication Setting Set and then get Device Token
        
        if let window = window {
            let homeController = HomeController()
            SlideMenu.shared.baseDelegate = homeController
            rootNavigationController = UINavigationController(rootViewController: homeController)
            window.rootViewController = rootNavigationController
            window.makeKeyAndVisible()
        }
        return true
    }
    
    // Device Token Setting -> APNs Token Setting to FCM -> get FCMToken and Set Local UserDefaults
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // FCM Token is null일 경우, APNs Token이 FCM에 셋팅이 되지 않았다는 것을 의미하고, 그렇기 때문에
        // FCM == null -> setAPNsToken을 실행해주어야 한다.
        // 계속 setAPNSToken을 실행할 경우, 그에 따른 FCM Token도 계속 바뀌기 때문에 제한을 두어야 함.
        print("Register Device Token: ", Messaging.messaging().fcmToken ?? "TOKEN IS NULL")
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        switch (application.applicationState) {
        case .inactive: print("inactive")
        case .background : print("background")
        case .active : print("active")
        }
        debugPrint("didReceiveRemoteNotification : \(userInfo)")
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        switch (application.applicationState) {
        case .inactive: print("inactive")
        case .background : print("background")
        case .active : print("active")
        }
        debugPrint("didReceiveRemoteNotification fetchCompletionHandler : \(userInfo)")
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        debugPrint("userNotificationCenter willPresent : \(userInfo)")
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        debugPrint("userNotificationCenter didReceive : \(userInfo)")
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("** FCM refreshing token : \(fcmToken)")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(["token": fcmToken])
    }
    
    // Direct channel data messages are delivered here, on iOS 10.0+.
    // The `shouldEstablishDirectChannel` property should be be set to |true| before data messages can
    // arrive.
    @available(iOS 10.0, *)
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        let message = JSON(remoteMessage.appData)
        print("Received direct channel message:\n\(message)")
    }
}



