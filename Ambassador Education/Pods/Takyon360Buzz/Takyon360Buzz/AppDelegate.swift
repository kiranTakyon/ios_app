//
//  AppDelegate.swift
//  Takyon360Buzz
//
//  Created by Sreeshaj Kp on 26/07/17.
//  Copyright © 2017 Sreeshaj Kp. All rights reserved.
//

import UIKit

var urlQueryValue = ""


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        
          var username = ""
           var password = ""
        
            let urlStr = "\(url)"
        let str = urlStr.components(separatedBy: "://")
        if str.count > 1{
            if let secondValue = str[1] as? String{
                let componets = secondValue.components(separatedBy: "&")
                if componets.count > 0{
                    let firstObj = componets[0] as? String
                    if  let equalSeperatedFirst = firstObj?.components(separatedBy: "="){
                    if equalSeperatedFirst.count > 1{
                        username = equalSeperatedFirst[1]
                    }
                    }
                    let secondObj = componets[1] as? String
                    if  let equalSeperatedSecond = secondObj?.components(separatedBy: "="){
                    if equalSeperatedSecond.count > 1{
                        password = equalSeperatedSecond[1]
                    }
                    }
                }
                UserDefaultsManager.manager.insertUserDefaultValue(value: username ?? "", key: DBKeys.username)
                UserDefaultsManager.manager.insertUserDefaultValue(value:password ?? "", key: DBKeys.password)
                
                if UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.username) as? String != ""{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CallPostLoaginApi"), object: nil)
                }
            }
        }
       

        urlQueryValue = url.query.safeValue
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

