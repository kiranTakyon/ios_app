//
//  jsonKeys.swift
//  Ambassador Education
//
//     on 05/05/17.
//   . All rights reserved.
//

import Foundation
import UIKit


struct LogInKeys{
    let platform = "Platform"
    let username = "UserName"
    let password = "Password"
    let language = "Language"
}

class DBKeys{
    
    static  let logInDetails = "logInDetails"
    static  let profileInfo = "ProfileInfo"
    static  let username = "username"
    static  let password = "passwdord"
    static  let FTPDetails = "FTPDetails"
}

class JsonKeys{
    
    let message = "MSG"
    let status = "status"
    
}


//MARK:- UserDefaults Keys


struct UserDefaultKeys{
    
    let userDetails = "UserDetails"
    let AccessToken = "AccessToken"
}


extension UIColor{
    
    class func appOrangeColors() -> UIColor
    {
        return UIColor.colorFromHEX(hexValue: 0xE9503B)
    }
  
}
