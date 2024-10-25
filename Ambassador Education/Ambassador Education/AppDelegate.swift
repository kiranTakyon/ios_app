//
//  AppDelegate.swift
//  Ambassador Education
//
//     on 04/05/17.
//   . All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FirebaseCore
import FirebaseMessaging
import Messages
import SwiftSoup
import Updates
import GoogleSignIn
//import Google
var wasLaunchedFromNotification: Bool = false
var remoteNotification: NSDictionary?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"
    
    let gcmMessageIDKey = "gcm.message_id"
    var appId = ""

    
    //#if ORISONSCHOOLV2
    //    let value = 1
    //#elseif TARGET_B
    //    let value = 2
    //#elseif TARGET_C
    //    let value = 3
    //// Add more targets and values as needed
    //#else
    //    let value = 0 // Default value if no target-specific macro is defined
    //#endif
    
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //   FirebaseApp.configure()
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        //FirebaseApp.configure()
        setFireBase(application : application)
        //    FirebaseApp.configure()
        googleSignInConfiguration()
        UIApplication.shared.applicationIconBadgeNumber = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {  /// Showing dealy for update popup on top view
            self.showUpdateAppAlert()
        }

        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            print("App launched from notification with userInfo: \(notification)")
            remoteNotification = notification as NSDictionary
            wasLaunchedFromNotification = true
        } else {
            wasLaunchedFromNotification = false
        }
        return true
    }
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    //dQoi3apC9w8:APA91bF1T1ICXglY8pi48IKUr9EoE0MJ756AEVVf0xElpVaXCmdXGBUoqbJsedWmC9ztj3SbdEdgqRPMRSaBwbu63aD0vOTXtseeK7VIEut3-tP9RRp3E7AhmgAvHB8cJ4Xx9EzgbeXR
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        
        Messaging.messaging().subscribe(toTopic: subscriptionTopic) { error in
            print("Subscribed to \(self.subscriptionTopic)")
            self.subscribedToTopic = true
        }
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
    }
    
    // [START receive_message]
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        // Handle the received message
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: messageKey), object: nil,
                                        userInfo: userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // [END receive_message]
    // [START disconnect_gcm_service]
    /*   func applicationDidEnterBackground(_ application: UIApplication) {
     GCMService.sharedInstance().disconnect()
     // [START_EXCLUDE]
     self.connectedToGCM = false
     // [END_EXCLUDE]
     }
     */  // [END disconnect_gcm_service]
    
    func setFireBase(application : UIApplication){
        
        var configureError: NSError?
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        updateFirestorePushTokenIfNeeded()
        // [END register_for_notifications]
        
        
        
        //GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
        // gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        // [END_EXCLUDE]
        
        // [START start_gcm_service]
        /* let gcmConfig = GCMConfig.default()
         gcmConfig?.receiverDelegate = self
         GCMService.sharedInstance().start(with: gcmConfig)
         */
    }
    
    func saveGCMTokenToUserDefaults(token : String){
        UserDefaultsManager.manager.insertUserDefaultValue(value: token, key: DBKeys.gcmToken)
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let registrationToken = Messaging.messaging().fcmToken{
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            saveGCMTokenToUserDefaults(token : self.registrationToken.safeValue)
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: ")
            let userInfo = ["error": "unknown"]
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: self.registrationKey), object: nil, userInfo: userInfo)
        }
    }
    
    // [START upstream_callbacks]
    func willSendDataMessage(withID messageID: String!, error: Error!) {
        if error != nil {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    
    // [START receive_apns_token_error]
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
        // [END receive_apns_token_error]
        let userInfo = ["error": error.localizedDescription]
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: registrationKey), object: nil, userInfo: userInfo)
    }
    
    func didSendDataMessage(withID messageID: String!) {
        // Did successfully send message identified by messageID
    }
    // [END upstream_callbacks]
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.alert, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.messageKey), object: nil,
                                            userInfo: userInfo)
        }

        completionHandler()
    }
}

// [END ios_10_message_handling]

extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        updateFirestorePushTokenIfNeeded()
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    // [END refresh_token]
}

//Google Sign in
extension AppDelegate {
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func googleSignInConfiguration() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        print(clientID)
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
}


extension AppDelegate {
    
    func showUpdateAppAlert() {
#if CREDENCESCHOOL
        let appStoreId = ""
#elseif NEWACADEMYSCHOOL
        let appStoreId = ""
#elseif AMLEDSCHOOL
        let appStoreId = ""
#elseif EFIA
        let appStoreId = ""
#elseif ABC
        let appStoreId = ""
#elseif SAMA
        let appStoreId = ""
#elseif ASIANINTERNATIONAL
        let appStoreId = ""
#elseif RAK_ACADEMY
        let appStoreId = ""
#elseif RENAISSANCE_SCHOOL
        let appStoreId = ""
#elseif QUALITY_EDUCATION
        let appStoreId = ""
#elseif SALMIYA
        let appStoreId = ""
#elseif BIS
        let appStoreId = ""
#elseif PEA
        let appStoreId = ""
#elseif DAR_AL_ULOOM
        let appStoreId = ""
#elseif SMS
        let appStoreId = ""
#elseif SAHODAYSCHOOL
        let appStoreId = ""
#elseif AJMAN_MODERN
        let appStoreId = ""
#elseif PEPS_V2
        let appStoreId = "1534894835"
#elseif ALMAWAHIB
        let appStoreId = ""
#elseif AJMANMODERN
        let appStoreId = ""
#elseif CITY_V2
        let appStoreId = ""
#elseif ALANSAR
        let appStoreId = ""
#elseif LPS
        let appStoreId = "1584985565"
#elseif OUROWN
        let appStoreId = ""
#elseif ATHENA_EDUCATION
        let appStoreId = "1610359345"
#elseif RAKSCHOLARS_V2
        let appStoreId = ""
#elseif ICS
        let appStoreId = "1596812393"
#elseif ALAMEER_V2
        let appStoreId = ""
#elseif ORISONSCHOOL_V2
        let appStoreId = "1487457408"
#elseif AJYAL
        let appStoreId = "1489710536"
#elseif T360
        let appStoreId = ""
#elseif CRESENT
        let appStoreId = "1584652255"
#elseif SSI
        let appStoreId = ""
#elseif HABITAT
        let appStoreId = "1488104801"
#elseif PEA_V2
        let appStoreId = ""
#elseif VIS
        let appStoreId = "6448665301"
#elseif AMANA
        let appStoreId = ""
#elseif MSB
        let appStoreId = "1487692610"
#elseif TARYAM
        let appStoreId = "1490576039"
#elseif FUTURE_LEADERS
        let appStoreId = "1484489965"
#elseif AMBASSADOR
        let appStoreId = "1487778928"
#elseif WPS
        let appStoreId = "6474555846"
#elseif AIQN
        let appStoreId = "6476014314"
#elseif EPS
        let appStoreId = "6698888081"
#else
        let appStoreId = ""
#endif
        Updates.updatingMode = .automatically
        Updates.notifying = .always
        Updates.appStoreId = appStoreId
        Updates.checkForUpdates { result in
            if let topVc = UIApplication.getTopViewController() {
                UpdatesUI.promptToUpdate(result, presentingViewController: topVc)
            }
        }
    }
}
