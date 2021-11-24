//
//  GlobalFunctions.swift
//  Takyon360Buzz
//
//  Created by Veena on 17/04/18.
//  Copyright © 2018 Sreeshaj Kp. All rights reserved.
//

import Foundation
import UIKit
import Darwin

@objc protocol BussProtocol {
    
    @objc optional func getBackToParentView(value:Any?)
    
}

let BaseUrl = "http://reportz.co.in/Takyon360/T360_API/"// //"http://lasagu.net/school/T360Api/"
let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
let kAppName = ""
var currentUserName = ""
var currentPassword = ""

func showLoginPage() {
    optionMsgs?.removeAll()
    removeAllGlbalValues()
    let appDeligate = UIApplication.shared.delegate as! AppDelegate
    let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
    appDeligate.window?.rootViewController = loginVC
    appDeligate.window?.makeKeyAndVisible()
}

func removeAllGlbalValues(){
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.logInDetails)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.FTPDetails)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.username)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.password)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.profileInfo)
    
    
}
func convertedToDataFromDict(dict : NSDictionary) -> Data?{
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
        return jsonData
    }
    catch _ {
        print("Error Exporting Db Dictionary")
    }
    return nil
}


func cleanDictionaryValues(dict: NSMutableDictionary)->NSMutableDictionary{
    let mutableDict: NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
    mutableDict.enumerateKeysAndObjects({ (key, obj, stop) -> Void in
        if (obj is NSNull) {
            mutableDict.setObject("", forKey: (key as! NSString))
        } else if (obj is NSDictionary) {
            print(obj)
            if (obj as! NSDictionary).allKeys.count > 0{
                mutableDict.setObject(cleanDictionaryValues(dict: obj as! NSMutableDictionary), forKey: (key as! NSString))
            }
            
        }
    })
    return mutableDict
}

func showLandscapeOnly(){
    let value = UIInterfaceOrientation.landscapeLeft.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
}


func showPortait(){
    let value = UIInterfaceOrientation.portrait.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
    
}

func cleanDictionary(dict: NSDictionary)->NSMutableDictionary{
    let mutableDict: NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
    mutableDict.enumerateKeysAndObjects({ (key, obj, stop) -> Void in
        
        if obj is NSNull {
            print(obj)
        }
        
        if obj is NSNull {
            print(obj)
            mutableDict.setObject("", forKey: (key as! NSString))
        } else if obj is NSDictionary {
            print(obj)
            if (obj as! NSDictionary).allKeys.count > 0{
                mutableDict.setObject(cleanDictionary(dict: obj as! NSDictionary), forKey: (key as! NSString))
            }
            
        }
    })
    return mutableDict
}
