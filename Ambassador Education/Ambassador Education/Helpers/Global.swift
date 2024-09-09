//
//  Global.swift
//  PosBook
//
//     on 14/07/17.
//   . All rights reserved.
//

import Foundation
import UIKit
import WebKit

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

func addBlurEffectToTableView(inputView: UIView,hide : Bool){
    let blur = UIBlurEffect(style: .light)
    inputView.alpha = 1.0
    let blurView = UIVisualEffectView(effect: blur)
    blurView.tag  = 111111
    blurView.alpha = 0.5
    
    blurView.frame = inputView.bounds
    if !hide{
        blurView.isHidden = false
        inputView.isUserInteractionEnabled = false
        inputView.addSubview(blurView)
    }
    else{
        if let view = inputView.viewWithTag(111111) as? UIVisualEffectView{
            view.isHidden = true
            inputView.isUserInteractionEnabled = true
            view.removeFromSuperview()
        }
    }
}


func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

func checkDictionary(dict:NSDictionary) -> NSMutableDictionary
{
    var mutableDict = NSMutableDictionary(dictionary: dict)
    
    
    
    let keys = Array(mutableDict.allKeys)
    for i in keys
    {
        let checkvalue = mutableDict.value(forKey: i as! String)
        if checkvalue is NSNull
        {
            mutableDict.setObject("", forKey: i as! NSString)
        }
        else if checkvalue is NSNull
        {
            let dic = checkvalue as! NSDictionary
            let dicts = dic.mutableCopy()
          let vv =  checkDictionary(dict: dicts as! NSDictionary)
            mutableDict.setObject(vv, forKey: i as! NSString)
        }
        else if let checkValu2 = checkvalue as? NSArray
        {
            let keys2 = checkValu2
            let keys1 = NSMutableArray(array: keys2)//keys2.mutableCopy() as! NSArray
            mutableDict.setObject(keys1, forKey: i as! NSString)
            for j in keys1
            {
                if j is NSNull
                {
                    keys1.replaceObject(at: keys1.index(of: j), with:"")
                }
                if j is NSDictionary
                {
                    let dic = j as! NSDictionary
                    let dicts = dic.mutableCopy()
                    keys1.replaceObject(at: keys1.index(of: j), with: dicts)
                   let ff = checkDictionary(dict: dicts as! NSDictionary)
                    mutableDict = ff
                }
            }
        }
    }
    
    
    
    
    mutableDict = NSMutableDictionary(dictionary: dict);
    
    return mutableDict
}


 func removeNullsFromDictionary(origin:NSDictionary) -> NSMutableDictionary {
    var destination = NSMutableDictionary()
    for key in origin.allKeys {
        if origin[key] != nil && !(origin[key] is NSNull){
            if origin[key] is NSDictionary {
                destination[key] = removeNullsFromDictionary(origin: origin[key] as! NSDictionary)
            } else if (origin[key] is NSArray){
                let orgArray = origin[key] as! NSArray
                var destArray = [NSMutableDictionary]()
                for item in orgArray {
                    if item is NSDictionary {
                        destArray.append(removeNullsFromDictionary(origin: item as! NSDictionary))
                    } else {
                        destArray.append(item as! NSMutableDictionary)
                    }
                }
            } else {
                destination[key] = origin[key]
            }
        } else {
            destination[key] = "" as AnyObject
        }
    }
    return destination
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

func showLoginPage() {
    let appDeligate = UIApplication.shared.delegate as! AppDelegate
    let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
    
    if UserDefaultsManager.manager.getRemember() {
        guard let username = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.username) as? String else {return}
        guard let password = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.password) as? String else {return}
        loginVC.rememberEmail = username
        loginVC.rememberPassword = password
        loginVC.isRemember = true
    }
    removeAllGlbalValues()
    appDeligate.window?.rootViewController = loginVC
    appDeligate.window?.makeKeyAndVisible()
}


func removeAllGlbalValues(){
    currentPassword = ""
    currentUserName = ""
    currentLanguage = ""
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.logInDetails)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.FTPDetails)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.username)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.password)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.userIdValue)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.profileInfo)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.gcmToken)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.isNotifications)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.isRemember)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.refresh_token)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.session_Token)
    UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.logInResponse)

}

func MD5(string: String) -> Data {
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    
    _ = digestData.withUnsafeMutableBytes {digestBytes in
        messageData.withUnsafeBytes {messageBytes in
            CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
        }
    }
    
    
    
    
    return digestData
}

func convertToTimeFormat(fromFormat:String,toFormat:String,date:Date) -> String?{
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = toFormat
    let dateStr = dateFormatter.string(from: date)
    
    return dateStr
}

func temp(str : String) -> Date{
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    let date = dateFormatter.date(from: str)
    return date!
}

func changetoDiffFormatInDate(value:String,fromFormat: String,toFormat:String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFormat
    if let anAbbreviation = NSTimeZone(abbreviation: "UTC") {
        dateFormatter.timeZone = anAbbreviation as TimeZone
    }
    let date: Date? = dateFormatter.date(from: value)
    dateFormatter.dateFormat = toFormat
    dateFormatter.timeZone = NSTimeZone.local
    if let aDate = date {
        let timestamp = dateFormatter.string(from: aDate)
        if let dateTime = dateFormatter.date(from: timestamp) {
            return dateTime
        }
    }
    return Date()
}


func convertToDate(dateVal:String) -> Date{
    
    let dateFormatter = DateFormatter()
    let tempLocale = dateFormatter.locale // save locale temporarily
    dateFormatter.locale = tempLocale//Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "dd-mm-yyyy"
    let date = dateFormatter.date(from: dateVal)!
    return date
    
}


func dateConvert(dateVal:String){
    
    let string = dateVal
    
    let dateFormatter = DateFormatter()
    let tempLocale = dateFormatter.locale // save locale temporarily
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let date = dateFormatter.date(from: string)!
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    dateFormatter.locale = tempLocale // reset the locale
    let dateString = dateFormatter.string(from: date)
    print("EXACT_DATE : \(dateString)")
}

class Downloader {
    class func load(url: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request =  URLRequest(url: url)//URLRequest(url: url, method: .get)url
        
        let documentsPath = getDirectoryPath()//
        
        print("document file \(documentsPath)")
        //NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
               
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    let documentUrl = URL(fileURLWithPath: documentsPath)
                    try FileManager.default.copyItem(at: tempLocalUrl, to: documentUrl)
                    completion()
                    print("Pdf succesfully downloaded")
                } catch (let writeError) {
                    print("error writing file \(documentsPath) : \(writeError)")
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
    }
}

func presentAllDownLoadPage(vcs : UIViewController){
//    let vc = mainStoryBoard.instantiateViewController(withIdentifier: "DownLoadsViewController") as? DownLoadsViewController
//    vcs.present(vc!, animated: true, completion: nil)
}

func getDirectoryPath() -> String{
    
           let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    return documentsPath
}

//MARK:- Common Enums


enum UserType : String {
    case student = "student"
    case teacher = "teacher"
    case parent = "parent"
    case admin = "admin"
}


class DateTypes{
    
    static let mmmddyyy = "MMM dd, YYYY"
    static let mmddYYYY = "dd-MM-YYYY"
    static let mmddyyyy = "dd-MM-yyyy"
    static let yyyMMdd = "YYYY-MM-dd"
    static let yyyyMMdd = "yyyy-MM-dd"
    static let ddmmyyyy = "dd/MM/YYYY"


}


